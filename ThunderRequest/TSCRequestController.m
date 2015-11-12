#import "TSCRequestController.h"
#import "TSCRequest.h"
#import "TSCRequestResponse.h"
#import "TSCErrorRecoveryAttempter.h"
#import "TSCErrorRecoveryOption.h"
#import "TSCRequestCredential.h"
#import "NSURLSession+Synchronous.h"
#import "NSThread+Blocks.h"
#import "TSCOAuth2Credential.h"
#import <objc/runtime.h>

static NSString * const TSCQueuedRequestKey = @"TSC_REQUEST";
static NSString * const TSCQueuedCompletionKey = @"TSC_REQUEST_COMPLETION";

@interface TSCRequest (TaskIdentifier)

/**
 @abstract Can be used to get the task back for the request
 */
@property (nonatomic, assign) NSUInteger taskIdentifier;

@end

@implementation TSCRequest (TaskIdentifier)

static char taskIdentifierKey;

- (NSUInteger)taskIdentifier
{
    return [objc_getAssociatedObject(self, &taskIdentifierKey) integerValue];
}

- (void)setTaskIdentifier:(NSUInteger)taskIdentifier
{
    objc_setAssociatedObject(self, &taskIdentifierKey, @(taskIdentifier), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

typedef void (^TSCOAuth2CheckCompletion) (BOOL authenticated, NSError *authError, BOOL needsQueueing);

@interface TSCRequestController () <NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>

/**
 @abstract The operation queue that contains all requests added to a default session
 */
@property (nonatomic, strong) NSOperationQueue *defaultRequestQueue;

/**
 @abstract The operation queue that contains all requests added to a background session
 */
@property (nonatomic, strong) NSOperationQueue *backgroundRequestQueue;

/**
 @abstract The operation queue that contains all requests added to a ephemeral session
 */
@property (nonatomic, strong) NSOperationQueue *ephemeralRequestQueue;

/**
 @abstract Uses persistent disk-based cache and stores credentials in the user's keychain
 */
@property (nonatomic, strong) NSURLSession *defaultSession;

/**
 @abstract Does not store any data on the disk; all caches, credential stores, and so on are kept in the RAM and tied to the session. Thus, when invalidated, they are purged automatically.
 */
@property (nonatomic, strong) NSURLSession *backgroundSession;

/**
 @abstract Similar to a default session, except that a seperate process handles all data transfers. Background sessions have some additional limitations.
 */
@property (nonatomic, strong) NSURLSession *ephemeralSession;

/**
 @abstract Defines whether or not verbose logging of requests and responses is enabled. Defined by setting "TSCThunderRequestVerboseLogging" boolean in info plsit
 */
@property (nonatomic) BOOL verboseLogging;

/**
 @abstract Defines whether or not verbose logging should include the full response body or a truncated version
 */
@property (nonatomic) BOOL truncatesVerboseResponse;

/**
 @abstract A dictionary of completion handlers to be called when file downloads are complete
 */
@property (nonatomic, strong) NSMutableDictionary *completionHandlerDictionary;

/**
 @abstract Whether we are currently re-authenticating or not
 */
@property (nonatomic, assign) BOOL reAuthenticating;

/**
 @abstract An array of TSCRequest objects which are waiting for re-authentication to complete
 */
@property (nonatomic, strong) NSMutableArray *authQueuedRequests;

/**
 @abstract A dictionary representing any re-direct responses provided with a redirect request
 @discussion These will be added onto the TSCRequestResponse object of the re-directed request, they are stored in this request under the request object itself
 */
@property (nonatomic, strong) NSMutableDictionary *redirectResponses;

@end

@implementation TSCRequestController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.verboseLogging = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"TSCThunderRequestVerboseLogging"] boolValue];
        self.truncatesVerboseResponse = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"TSCThunderRequestTruncatesVerboseResponse"] boolValue];
        
        self.defaultRequestQueue = [NSOperationQueue new];
        self.backgroundRequestQueue = [NSOperationQueue new];
        self.ephemeralRequestQueue = [NSOperationQueue new];
        
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[[NSUUID UUID] UUIDString]];
        NSURLSessionConfiguration *ephemeralConfigObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        self.defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:self.defaultRequestQueue];
        self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigObject delegate:self delegateQueue:self.backgroundRequestQueue];
        self.ephemeralSession = [NSURLSession sessionWithConfiguration:ephemeralConfigObject delegate:nil delegateQueue:self.ephemeralRequestQueue];
        
        self.completionHandlerDictionary = [NSMutableDictionary dictionary];
        self.sharedRequestHeaders = [NSMutableDictionary dictionary];

        self.authQueuedRequests = [NSMutableArray new];
        self.redirectResponses = [NSMutableDictionary new];
    }
    return self;
}

- (nonnull instancetype)initWithBaseURL:(nonnull NSURL *)baseURL
{
    self = [self init];
    if (self) {
        
        if ([baseURL.absoluteString hasSuffix:@"/"]) {
            self.sharedBaseURL = baseURL;
        } else {
            self.sharedBaseURL = [NSURL URLWithString:[baseURL.absoluteString stringByAppendingString:@"/"]];
        }
        
        self.sharedRequestCredential = [TSCRequestCredential retrieveCredentialWithIdentifier:[NSString stringWithFormat:@"thundertable.com.threesidedcube-%@", self.sharedBaseURL]];
    }
    return self;
}

- (nonnull instancetype)initWithBaseAddress:(nonnull NSString *)baseAddress
{
    return [self initWithBaseURL:[NSURL URLWithString:baseAddress]];
}

#pragma mark - GET Requests

- (nonnull TSCRequest *)get:(nonnull NSString *)path completion:(nonnull TSCRequestCompletionHandler)completion
{
    return [self get:path withURLParamDictionary:nil completion:completion];
}

- (nonnull TSCRequest *)get:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary completion:(nonnull TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.requestHTTPMethod = TSCRequestHTTPMethodGET;
    request.path = path;
    request.URLParameterDictionary = URLParamDictionary;
    request.requestHeaders = self.sharedRequestHeaders;

    [self scheduleRequest:request completion:completion];
    return request;
}

#pragma mark - POST Requests

- (nonnull TSCRequest *)post:(nonnull NSString *)path bodyParams:(nullable NSDictionary *)bodyParams completion:(nonnull TSCRequestCompletionHandler)completion
{
    return [self post:path withURLParamDictionary:nil bodyParams:bodyParams completion:completion];
}

- (nonnull TSCRequest *)post:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary bodyParams:(nullable NSDictionary *)bodyParams completion:(nonnull TSCRequestCompletionHandler)completion
{
    return [self post:path withURLParamDictionary:URLParamDictionary bodyParams:bodyParams contentType:TSCRequestContentTypeJSON completion:completion];
}

- (nonnull TSCRequest *)post:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary bodyParams:(nullable NSDictionary *)bodyParams contentType:(TSCRequestContentType)contentType completion:(nonnull TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.path = path;
    request.requestHTTPMethod = TSCRequestHTTPMethodPOST;
    request.bodyParameters = bodyParams;
    request.URLParameterDictionary = URLParamDictionary;
    request.contentType = contentType;
    request.requestHeaders = self.sharedRequestHeaders;

    [self scheduleRequest:request completion:completion];
    return request;
}

#pragma mark - PUT Requests
- (nonnull TSCRequest *)put:(nonnull NSString *)path bodyParams:(nullable NSDictionary *)bodyParams completion:(nonnull TSCRequestCompletionHandler)completion
{
    return [self put:path withURLParamDictionary:nil bodyParams:bodyParams completion:completion];
}

- (nonnull TSCRequest *)put:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary bodyParams:(nullable NSDictionary *)bodyParams completion:(nonnull TSCRequestCompletionHandler)completion
{
    return [self put:path withURLParamDictionary:URLParamDictionary bodyParams:bodyParams contentType:TSCRequestContentTypeJSON completion:completion];
}

- (nonnull TSCRequest *)put:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary bodyParams:(nullable NSDictionary *)bodyParams contentType:(TSCRequestContentType)contentType completion:(nonnull TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.path = path;
    request.requestHTTPMethod = TSCRequestHTTPMethodPUT;
    request.bodyParameters = bodyParams;
    request.URLParameterDictionary = URLParamDictionary;
    request.contentType = contentType;
    request.requestHeaders = self.sharedRequestHeaders;

    [self scheduleRequest:request completion:completion];
    return request;
}

#pragma mark - DELETE Requests

- (nonnull TSCRequest *)delete:(nonnull NSString *)path completion:(nonnull TSCRequestCompletionHandler)completion
{
    return [self delete:path withURLParamDictionary:nil completion:completion];
}

- (nonnull TSCRequest *)delete:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary completion:(nonnull TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.requestHTTPMethod = TSCRequestHTTPMethodDELETE;
    request.path = path;
    request.URLParameterDictionary = URLParamDictionary;
    request.requestHeaders = self.sharedRequestHeaders;

    [self scheduleRequest:request completion:completion];
    return request;
}

#pragma mark - HEAD Requests

- (nonnull TSCRequest *)head:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary completion:(nonnull TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.requestHTTPMethod = TSCRequestHTTPMethodHEAD;
    request.path = path;
    request.URLParameterDictionary = URLParamDictionary;
    request.requestHeaders = self.sharedRequestHeaders;

    [self scheduleRequest:request completion:completion];
    return request;
}

#pragma mark - DOWNLOAD/UPLOAD Requests

- (void)downloadFileWithPath:(nonnull NSString *)path progress:(nullable TSCRequestProgressHandler)progress completion:(nonnull TSCRequestTransferCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.path = path;
    request.requestHTTPMethod = TSCRequestHTTPMethodGET;
    request.requestHeaders = self.sharedRequestHeaders;

    [self scheduleDownloadRequest:request progress:progress completion:completion];
}

- (void)uploadFileFromPath:(nonnull NSString *)filePath toPath:(nonnull NSString *)path progress:(nullable TSCRequestProgressHandler)progress completion:(nonnull TSCRequestTransferCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.path = path;
    request.requestHTTPMethod = TSCRequestHTTPMethodPOST;
    request.requestHeaders = self.sharedRequestHeaders;
    
    [self scheduleUploadRequest:request filePath:filePath progress:progress completion:completion];
}

- (void)uploadFileData:(nonnull NSData *)fileData toPath:(nonnull NSString *)path progress:(nullable TSCRequestProgressHandler)progress completion:(nonnull TSCRequestTransferCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.path = path;
    request.requestHTTPMethod = TSCRequestHTTPMethodPOST;
    request.requestHeaders = self.sharedRequestHeaders;
    request.HTTPBody = fileData;
    
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

    NSString *filePathString = [cachesDirectory stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    [fileData writeToFile:filePathString atomically:YES];
    
    [self scheduleUploadRequest:request filePath:filePathString progress:progress completion:completion];
}

- (void)uploadFileData:(nonnull NSData *)fileData toPath:(nonnull NSString *)path contentType:(TSCRequestContentType)type progress:(nullable TSCRequestProgressHandler)progress completion:(nonnull TSCRequestTransferCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.path = path;
    request.requestHTTPMethod = TSCRequestHTTPMethodPOST;
    request.requestHeaders = self.sharedRequestHeaders;
    request.contentType = type;
    request.HTTPBody = fileData;
    
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *filePathString = [cachesDirectory stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    [fileData writeToFile:filePathString atomically:YES];
    
    [self scheduleUploadRequest:request filePath:filePathString progress:progress completion:completion];
}

- (void)uploadBodyParams:(nullable NSDictionary *)bodyParams toPath:(nonnull NSString *)path contentType:(TSCRequestContentType)type progress:(nullable TSCRequestProgressHandler)progress completion:(nonnull TSCRequestTransferCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.path = path;
    request.requestHTTPMethod = TSCRequestHTTPMethodPOST;
    request.requestHeaders = self.sharedRequestHeaders;
    request.contentType = type;
    request.bodyParameters = bodyParams;
    
    [self scheduleUploadRequest:request filePath:nil progress:progress completion:completion];
    
}

- (void)TSC_fireRequestCompletionWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error request:(TSCRequest *)request completion:(TSCRequestCompletionHandler)completion onThread:(NSThread *)scheduleThread
{
    TSCRequestResponse *requestResponse = [[TSCRequestResponse alloc] initWithResponse:response data:data];
    
    if (request.taskIdentifier && self.redirectResponses[@(request.taskIdentifier)]) {
        requestResponse.redirectResponse = self.redirectResponses[@(request.taskIdentifier)];
        [self.redirectResponses removeObjectForKey:@(request.taskIdentifier)];
    }
    
    //Notify of response
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCRequestDidReceiveResponse" object:requestResponse];
    
    //Notify of errors
    if ([self statusCodeIsConsideredHTTPError:requestResponse.status]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCRequestServerError" object:self];
        
    }
    
    if (error || [self statusCodeIsConsideredHTTPError:requestResponse.status]) {
        
        TSCErrorRecoveryAttempter *recoveryAttempter = [TSCErrorRecoveryAttempter new];
        
        [recoveryAttempter addOption:[TSCErrorRecoveryOption optionWithTitle:@"Retry" type:TSCErrorRecoveryOptionTypeRetry handler:^(TSCErrorRecoveryOption *option) {
            
            [self scheduleRequest:request completion:completion];
            
        }]];
        
        [recoveryAttempter addOption:[TSCErrorRecoveryOption optionWithTitle:@"Cancel" type:TSCErrorRecoveryOptionTypeCancel handler:nil]];
        
        [scheduleThread performBlock:^{
            
            if (error) {
                completion(requestResponse, [recoveryAttempter recoverableErrorWithError:error]);
            } else {
                
                NSError *httpError = [NSError errorWithDomain:TSCRequestErrorDomain code:requestResponse.status userInfo:@{NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode:requestResponse.status]}];
                completion(requestResponse, [recoveryAttempter recoverableErrorWithError:httpError]);
                
            }
        }];
        
    } else {
        
        [scheduleThread performBlock:^{
            completion(requestResponse, error);
        }];
        
    }
    
    //Log
    if (self.verboseLogging) {
        
        if (error) {
            
            NSLog(@"Request:%@", request);
            NSLog(@"\n<ThunderRequest>\nURL: %@\nMethod: %@\nRequest Headers:%@\nBody: %@\n\nResponse Status: FAILURE \nError Description: %@",request.URL, request.HTTPMethod, request.allHTTPHeaderFields, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding], error.localizedDescription);
        } else {
            
            [scheduleThread performBlock:^{
                
                NSRange truncatedRange = {0, MIN(requestResponse.string.length, 25)};
                truncatedRange = [requestResponse.string rangeOfComposedCharacterSequencesForRange:truncatedRange];
                
                NSLog(@"\n<ThunderRequest>\nURL:    %@\nMethod: %@\nRequest Headers:%@\nBody: %@\n\nResponse Status: %li\nResponse Body: %@\n",request.URL, request.HTTPMethod, request.allHTTPHeaderFields, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding], (long)requestResponse.status, self.truncatesVerboseResponse ? [[requestResponse.string substringWithRange:truncatedRange] stringByAppendingString:@"..."] : requestResponse.string);
            }];
            
        }
    }
}

#pragma mark - Request scheduling

// This method is used to check the OAuth2 status before starting a request
- (void)checkOAuthStatusWithRequest:(TSCRequest *)request completion:(TSCOAuth2CheckCompletion)completion
{
    // If we have an OAuth2 delegate and the request isn't the request to refresh our token
    if (self.OAuth2Delegate) {
        
        if (!self.sharedRequestCredential || ![self.sharedRequestCredential isKindOfClass:[TSCOAuth2Credential class]]) {
            self.sharedRequestCredential = [TSCOAuth2Credential retrieveCredentialWithIdentifier:[self.OAuth2Delegate serviceIdentifier]];
        }
        
        // If we got shared credentials and they are OAuth 2 credentials we can continue
        if (self.sharedRequestCredential && [self.sharedRequestCredential isKindOfClass:[TSCOAuth2Credential class]]) {
            
            TSCOAuth2Credential *OAuth2Credential = (TSCOAuth2Credential *)self.sharedRequestCredential;
            
            // If our credentials have expired, and we don't already have a re-authentication request let's ask our delegate to refresh them
            if (OAuth2Credential.hasExpired && !self.reAuthenticating) {
                
                __weak typeof(self) welf = self;
                
                // Important so if the re-authenticating call uses this request controller we don't end up in an infinite loop! :P (My bad guys! (Simon))
                self.reAuthenticating = true;
                
                [self.OAuth2Delegate reAuthenticateCredential:OAuth2Credential withCompletion:^(TSCOAuth2Credential * __nullable credential, NSError * __nullable error, BOOL saveToKeychain) {
                    
                    // If we don't get an error we save the credentials to the keychain and then call the completion block
                    if (!error) {
                        
                        if (saveToKeychain) {
                            [TSCOAuth2Credential storeCredential:credential withIdentifier:[welf.OAuth2Delegate serviceIdentifier]];
                        }
                        welf.sharedRequestCredential = credential;
                    }
                    
                    // Call back to the initial OAuth check
                    if (completion) {
                        completion(error == nil, error, false);
                    }
                    
                    // Re-schedule any requests that were queued whilst we were refreshing the OAuth token
                    for (NSDictionary *request in welf.authQueuedRequests.copy) {
                        [welf scheduleRequest:request[TSCQueuedRequestKey] completion:request[TSCQueuedCompletionKey]];
                    }
                    
                    welf.authQueuedRequests = [NSMutableArray new];
                    welf.reAuthenticating = false;
                    
                }];
                
            } else if (self.reAuthenticating) { // The OAuth2 token has expired, but this is not the request which will refresh it, this can optionally be queued by the user
                
                completion(false, nil, true);
                
            } else {
                
                completion(true, nil, false);
            }
        } else {
            completion(true, nil, false);
        }
    } else {
        
        if (completion) {
            completion(true, nil, false);
        }
    }
}

- (void)scheduleDownloadRequest:(TSCRequest *)request progress:(TSCRequestProgressHandler)progress completion:(TSCRequestTransferCompletionHandler)completion
{
    __weak typeof(self) welf = self;
    [request prepareForDispatch];
    
    // Check OAuth status before making the request
    [self checkOAuthStatusWithRequest:request completion:^(BOOL authenticated, NSError *error, BOOL needsQueueing) {
       
        if (error || !authenticated) {
            
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        if (self.runSynchronously) {
            
            NSError *error = nil;
            NSURL *url = [welf.backgroundSession sendSynchronousDownloadTaskWithURL:request.URL returningResponse:nil error:&error];
            
            if (completion) {
                completion(url, error);
            }
            
        } else {
            
            // Should be using downloadtaskwithrequest but it has a bug which causes it to return nil.
            NSURLSessionDownloadTask *task = [welf.backgroundSession downloadTaskWithURL:request.URL];
            [welf addCompletionHandler:completion progressHandler:progress forTaskIdentifier:task.taskIdentifier];
            [task resume];
            
        }
    }];
}

- (void)scheduleUploadRequest:(nonnull TSCRequest *)request filePath:(NSString *)filePath progress:(nullable TSCRequestProgressHandler)progress completion:(nonnull TSCRequestTransferCompletionHandler)completion
{
    __weak typeof(self) welf = self;
    
    [self checkOAuthStatusWithRequest:request completion:^(BOOL authenticated, NSError *error, BOOL needsQueueing) {
        
        if (error || !authenticated) {
            
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        [request prepareForDispatch];
        
        if (self.runSynchronously) {
            
            NSError *error = nil;
            NSData *data;
            
            if (request.HTTPBody) {
                data = [welf.backgroundSession sendSynchronousUploadTaskWithRequest:[welf backgroundableRequestObjectFromTSCRequest:request] fromData:request.HTTPBody returningResponse:nil error:&error];
            } else {
                data = [welf.backgroundSession sendSynchronousUploadTaskWithRequest:[welf backgroundableRequestObjectFromTSCRequest:request] fromFile:[NSURL fileURLWithPath:filePath] returningResponse:nil error:&error];
            }
            
            if (completion) {
                completion(nil, error);
            }
            
        } else {
            
            NSURLSessionUploadTask *task;
            
            if (request.HTTPBody) {
                task = [welf.defaultSession uploadTaskWithRequest:[welf backgroundableRequestObjectFromTSCRequest:request] fromData:request.HTTPBody];
            } else {
                
                task = [welf.backgroundSession uploadTaskWithRequest:[welf backgroundableRequestObjectFromTSCRequest:request] fromFile:[NSURL fileURLWithPath:filePath]];
            }
            
            [welf addCompletionHandler:completion progressHandler:progress forTaskIdentifier:task.taskIdentifier];
            
            [task resume];
            
        }
    
    }];
}

- (void)scheduleRequest:(TSCRequest *)request completion:(TSCRequestCompletionHandler)completion
{
    // Check OAuth status before making the request
    __weak typeof(self) welf = self;
    [self checkOAuthStatusWithRequest:request completion:^(BOOL authenticated, NSError *error, BOOL needsQueueing) {
       
        if (error && !authenticated && !needsQueueing) {
            
            if (completion) {
                completion(nil, error);
            }
            return;
            
        } else if (needsQueueing) {
            
            // If we're not authenticated but didn't get an error then our request came inbetween calling re-authentication and getting
            [welf.authQueuedRequests addObject:@{TSCQueuedRequestKey:request,TSCQueuedCompletionKey:completion ? : ^( TSCRequestResponse *response, NSError *error){}}];
        }
        
        [request prepareForDispatch];
        
        if (welf.runSynchronously) {
            
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *data = [welf.defaultSession sendSynchronousDataTaskWithRequest:request returningResponse:&response error:&error];
            [welf TSC_fireRequestCompletionWithData:data response:response error:error request:request completion:completion onThread:[NSThread currentThread]];
            
        } else {
            
            NSThread *currentThread = [NSThread currentThread];
            NSURLSessionDataTask *dataTask = [welf.defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                [welf TSC_fireRequestCompletionWithData:data response:response error:error request:request completion:completion onThread:currentThread];
                
            }];
            
            request.taskIdentifier = dataTask.taskIdentifier;
            [dataTask resume];
        }
    }];
}

#pragma mark - NSURLSession challenge handling

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if (challenge.previousFailureCount == 0) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, self.sharedRequestCredential.credential);
        return;
    }
    
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task willPerformHTTPRedirection:(nonnull NSHTTPURLResponse *)response newRequest:(nonnull NSURLRequest *)request completionHandler:(nonnull void (^)(NSURLRequest * _Nullable))completionHandler
{
    self.redirectResponses[@(task.taskIdentifier)] = response;
    completionHandler(request);
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    CGFloat progress = (float)((float)totalBytesWritten /(float)totalBytesExpectedToWrite);
    
    [self callProgressHandlerForTaskIdentifier:downloadTask.taskIdentifier progress:progress totalBytes:(NSInteger)totalBytesExpectedToWrite progressBytes:(NSInteger)totalBytesWritten];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    [self callCompletionHandlerForTaskIdentifier:downloadTask.taskIdentifier downloadedFileURL:location downloadError:nil];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self callCompletionHandlerForTaskIdentifier:task.taskIdentifier downloadedFileURL:nil downloadError:error];
}

#pragma mark - NSURLSessionUploadDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    CGFloat progress = (float)((float)totalBytesSent /(float)totalBytesExpectedToSend);
    [self callProgressHandlerForTaskIdentifier:task.taskIdentifier progress:progress totalBytes:(NSInteger)totalBytesExpectedToSend progressBytes:(NSInteger)totalBytesSent];
}

#pragma mark - NSURLSessionDownload completion handling

- (void)addCompletionHandler:(TSCRequestTransferCompletionHandler)handler progressHandler:(TSCRequestProgressHandler)progress forTaskIdentifier:(NSUInteger)identifier
{
    NSString *taskIdentifierString = [NSString stringWithFormat:@"%lu-completion", (unsigned long)identifier];
    NSString *taskProgressIdentifierString = [NSString stringWithFormat:@"%lu-progress", (unsigned long)identifier];
    
    if ([self.completionHandlerDictionary objectForKey:taskIdentifierString]) {
        NSLog(@"Error: Got multiple handlers for a single task identifier.  This should not happen.\n");
    }
    
    [self.completionHandlerDictionary setObject:handler forKey:taskIdentifierString];
    
    if ([self.completionHandlerDictionary objectForKey:taskProgressIdentifierString]) {
        NSLog(@"Error: Got multiple progress handlers for a single task identifier.  This should not happen.\n");
    }
    
    [self.completionHandlerDictionary setObject:progress forKey:taskProgressIdentifierString];
}

- (void)callCompletionHandlerForTaskIdentifier:(NSUInteger)identifier downloadedFileURL:(NSURL *)fileURL downloadError:(NSError *)error
{
    NSString *taskIdentifierString = [NSString stringWithFormat:@"%lu-completion", (unsigned long)identifier];
    NSString *taskProgressIdentifierString = [NSString stringWithFormat:@"%lu-progress", (unsigned long)identifier];

    TSCRequestTransferCompletionHandler handler = [self.completionHandlerDictionary objectForKey:taskIdentifierString];
    
    if (handler) {
        
        [self.completionHandlerDictionary removeObjectsForKeys:@[taskIdentifierString, taskProgressIdentifierString]];
        
        handler(fileURL, error);
        
    }
}

- (void)callProgressHandlerForTaskIdentifier:(NSUInteger)identifier progress:(CGFloat)progress totalBytes:(NSInteger)total progressBytes:(NSInteger)bytes
{
    NSString *taskProgressIdentifierString = [NSString stringWithFormat:@"%lu-progress", (unsigned long)identifier];
    
    TSCRequestProgressHandler handler = [self.completionHandlerDictionary objectForKey:taskProgressIdentifierString];
    
    if (handler) {
        
        handler(progress, total, bytes);
        
    }

}

#pragma mark - Error handling

- (BOOL)statusCodeIsConsideredHTTPError:(NSInteger)statusCode
{
    if (statusCode >= 400 && statusCode < 600) {
        
        return true;
    }
    
    return false;
}

#pragma mark - OAuth2 Flow

- (void)setOAuth2Delegate:(id<TSCOAuth2Manager>)OAuth2Delegate
{
    _OAuth2Delegate = OAuth2Delegate;
    
    if (!OAuth2Delegate) {
        self.OAuth2RequestController = nil;
    }
    
    if (!OAuth2Delegate) {
        return;
    }
    
    TSCOAuth2Credential *credential = (TSCOAuth2Credential *)[TSCOAuth2Credential retrieveCredentialWithIdentifier:[OAuth2Delegate serviceIdentifier]];
    if (credential) {
        self.sharedRequestCredential = credential;
    }
}

- (TSCRequestController *)OAuth2RequestController
{
    if (!_OAuth2RequestController) {
        _OAuth2RequestController = [[TSCRequestController alloc] initWithBaseURL:self.sharedBaseURL];
    }
    
    return _OAuth2RequestController;
}

- (void)setSharedRequestCredential:(TSCRequestCredential *)credential andSaveToKeychain:(BOOL)save
{
    _sharedRequestCredential = credential;
    
    if ([_sharedRequestCredential isKindOfClass:[TSCOAuth2Credential class]]) {
        
        TSCOAuth2Credential *OAuthCredential = (TSCOAuth2Credential *)_sharedRequestCredential;
        self.sharedRequestHeaders[@"Authorization"] = [NSString stringWithFormat:@"%@ %@", OAuthCredential.tokenType, OAuthCredential.authorizationToken];
    }
    
    if (save) {
        [[credential class] storeCredential:credential withIdentifier: self.OAuth2Delegate ? [self.OAuth2Delegate serviceIdentifier] : [NSString stringWithFormat:@"thundertable.com.threesidedcube-%@", self.sharedBaseURL]];
    }
}

- (void)setSharedRequestCredential:(TSCRequestCredential *)sharedRequestCredential
{
    [self setSharedRequestCredential:sharedRequestCredential andSaveToKeychain:false];
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"finihed events for bg session");
}

#pragma mark - Request conversion

- (NSMutableURLRequest *)backgroundableRequestObjectFromTSCRequest:(TSCRequest *)tscRequest
{
    NSMutableURLRequest *backgroundableRequest = [NSMutableURLRequest new];
    backgroundableRequest.URL = tscRequest.URL;
    backgroundableRequest.HTTPMethod = [tscRequest stringForHTTPMethod:tscRequest.requestHTTPMethod];
    backgroundableRequest.HTTPBody = tscRequest.HTTPBody;
    
    for (NSString *key in [tscRequest.requestHeaders allKeys]) {
        [backgroundableRequest setValue:tscRequest.requestHeaders[key] forHTTPHeaderField:key];
    }
    
    return backgroundableRequest;
}

@end
