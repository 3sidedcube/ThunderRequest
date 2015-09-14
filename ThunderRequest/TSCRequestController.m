#import "TSCRequestController.h"
#import "TSCRequest.h"
#import "TSCRequestResponse.h"
#import "TSCErrorRecoveryAttempter.h"
#import "TSCErrorRecoveryOption.h"
#import "TSCRequestCredential.h"
#import "TSCOAuth2Credential.h"

typedef void (^TSCOAuth2CheckCompletion) (BOOL authenticated, NSError *authError);

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

- (void)get:(nonnull NSString *)path completion:(nonnull TSCRequestCompletionHandler)completion
{
    [self get:path withURLParamDictionary:nil completion:completion];
}

- (void)get:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary completion:(nonnull TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.requestHTTPMethod = TSCRequestHTTPMethodGET;
    request.path = path;
    request.URLParameterDictionary = URLParamDictionary;
    request.requestHeaders = self.sharedRequestHeaders;

    [self scheduleRequest:request completion:completion];
}

#pragma mark - POST Requests

- (void)post:(nonnull NSString *)path bodyParams:(nullable NSDictionary *)bodyParams completion:(nonnull TSCRequestCompletionHandler)completion
{
    [self post:path withURLParamDictionary:nil bodyParams:bodyParams completion:completion];
}

- (void)post:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary bodyParams:(nullable NSDictionary *)bodyParams completion:(nonnull TSCRequestCompletionHandler)completion
{
    [self post:path withURLParamDictionary:URLParamDictionary bodyParams:bodyParams contentType:TSCRequestContentTypeJSON completion:completion];
}

- (void)post:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary bodyParams:(nullable NSDictionary *)bodyParams contentType:(TSCRequestContentType)contentType completion:(nonnull TSCRequestCompletionHandler)completion
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
}

#pragma mark - PUT Requests
- (void)put:(nonnull NSString *)path bodyParams:(nullable NSDictionary *)bodyParams completion:(nonnull TSCRequestCompletionHandler)completion
{
    [self put:path withURLParamDictionary:nil bodyParams:bodyParams completion:completion];
}

- (void)put:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary bodyParams:(nullable NSDictionary *)bodyParams completion:(nonnull TSCRequestCompletionHandler)completion
{
    [self put:path withURLParamDictionary:URLParamDictionary bodyParams:bodyParams contentType:TSCRequestContentTypeJSON completion:completion];
}

- (void)put:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary bodyParams:(nullable NSDictionary *)bodyParams contentType:(TSCRequestContentType)contentType completion:(nonnull TSCRequestCompletionHandler)completion
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
}

#pragma mark - DELETE Requests

- (void)delete:(nonnull NSString *)path completion:(nonnull TSCRequestCompletionHandler)completion
{
    [self delete:path withURLParamDictionary:nil completion:completion];
}

- (void)delete:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary completion:(nonnull TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.requestHTTPMethod = TSCRequestHTTPMethodDELETE;
    request.path = path;
    request.URLParameterDictionary = URLParamDictionary;
    request.requestHeaders = self.sharedRequestHeaders;

    [self scheduleRequest:request completion:completion];
}

#pragma mark - HEAD Requests

- (void)head:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary completion:(nonnull TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.requestHTTPMethod = TSCRequestHTTPMethodHEAD;
    request.path = path;
    request.URLParameterDictionary = URLParamDictionary;
    request.requestHeaders = self.sharedRequestHeaders;

    [self scheduleRequest:request completion:completion];
}

#pragma mark - DOWNLOAD/UPLOAD Requests

- (void)downloadFileWithPath:(nonnull NSString *)path progress:(nullable TSCRequestProgressHandler)progress completion:(nonnull TSCRequestDownloadCompletionHandler)completion
{
    TSCRequest *request = [TSCRequest new];
    request.baseURL = self.sharedBaseURL;
    request.path = path;
    request.requestHTTPMethod = TSCRequestHTTPMethodGET;
    request.requestHeaders = self.sharedRequestHeaders;

    [self scheduleDownloadRequest:request progress:progress completion:completion];
}

#pragma mark - Request scheduling

// This method is used to check the OAuth2 status before starting a request
- (void)checkOAuthStatusWithCompletion:(TSCOAuth2CheckCompletion)completion
{
    // If we have an OAuth2 delegate and our credential has expired we call the delegate to refresh it
    if (self.OAuth2Delegate) {
        
        if (!self.sharedRequestCredential || ![self.sharedRequestCredential isKindOfClass:[TSCOAuth2Credential class]]) {
            self.sharedRequestCredential = [TSCOAuth2Credential retrieveCredentialWithIdentifier:[self.OAuth2Delegate serviceIdentifier]];
        }
        
        // If we got shared credentials and they are OAuth 2 credentials we can continue
        if (self.sharedRequestCredential && [self.sharedRequestCredential isKindOfClass:[TSCOAuth2Credential class]]) {
            
            TSCOAuth2Credential *OAuth2Credential = (TSCOAuth2Credential *)self.sharedRequestCredential;
            
            // If our credentials have expired, let's ask our delegate to refresh them
            if (OAuth2Credential.hasExpired) {
                
                __weak typeof(self) welf = self;
                [self.OAuth2Delegate reAuthenticateCredential:OAuth2Credential withCompletion:^(TSCOAuth2Credential * _Nullable credential, NSError * _Nullable error, BOOL saveToKeychain) {
                    
                    // If we don't get an error we save the credentials to the keychain and then call the completion block
                    if (!error) {
                        
                        if (saveToKeychain) {
                            [TSCOAuth2Credential storeCredential:credential withIdentifier:[welf.OAuth2Delegate serviceIdentifier]];
                        }
                        welf.sharedRequestCredential = credential;
                    }
                    
                    if (completion) {
                        completion(error != nil, error);
                    }
                }];
                
                return;
            } else {
                
                completion(true, nil);
            }
        } else {
            completion(true, nil);
        }
    } else {
        
        if (completion) {
            completion(true, nil);
        }
    }
}

- (void)scheduleDownloadRequest:(TSCRequest *)request progress:(TSCRequestProgressHandler)progress completion:(TSCRequestDownloadCompletionHandler)completion
{
    __weak typeof(self) welf = self;
    
    // Check OAuth status before making the request
    [self checkOAuthStatusWithCompletion:^(BOOL authenticated, NSError *error) {
       
        if (error || !authenticated) {
            
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        [request prepareForDispatch];
        
        // Should be using downloadtaskwithrequest but it has a bug which causes it to return nil.
        NSURLSessionDownloadTask *task = [welf.backgroundSession downloadTaskWithURL:request.URL];
        
        [welf addCompletionHandler:completion progressHandler:progress forTaskIdentifier:task.taskIdentifier];
        
        [task resume];
    }];
}

- (void)scheduleRequest:(TSCRequest *)request completion:(TSCRequestCompletionHandler)completion
{
    // Check OAuth status before making the request
    __weak typeof(self) welf = self;
    [self checkOAuthStatusWithCompletion:^(BOOL authenticated, NSError *error) {
       
        if (error || !authenticated) {
            
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        [request prepareForDispatch];
        [[welf.defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            TSCRequestResponse *requestResponse = [[TSCRequestResponse alloc] initWithResponse:response data:data];
            //Notify of response
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCRequestDidReceiveResponse" object:requestResponse];
            
            //Notify of errors
            if ([welf statusCodeIsConsideredHTTPError:requestResponse.status]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCRequestServerError" object:self];
                
            }
            
            if (error || [welf statusCodeIsConsideredHTTPError:requestResponse.status]) {
                
                TSCErrorRecoveryAttempter *recoveryAttempter = [TSCErrorRecoveryAttempter new];
                
                [recoveryAttempter addOption:[TSCErrorRecoveryOption optionWithTitle:@"Retry" type:TSCErrorRecoveryOptionTypeRetry handler:^(TSCErrorRecoveryOption *option) {
                    
                    [welf scheduleRequest:request completion:completion];
                    
                }]];
                
                [recoveryAttempter addOption:[TSCErrorRecoveryOption optionWithTitle:@"Cancel" type:TSCErrorRecoveryOptionTypeCancel handler:nil]];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    if (error) {
                        completion(requestResponse, [recoveryAttempter recoverableErrorWithError:error]);
                    } else {
                        
                        NSError *httpError = [NSError errorWithDomain:TSCRequestErrorDomain code:requestResponse.status userInfo:@{NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode:requestResponse.status]}];
                        
                        completion(requestResponse, [recoveryAttempter recoverableErrorWithError:httpError]);
                        
                    }
                }];
                
            } else {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    completion(requestResponse, error);
                    
                }];
                
            }
            
            
            //Log
            if (self.verboseLogging) {
                
                if (error) {
                    
                    NSLog(@"Request:%@", request);
                    NSLog(@"\n<ThunderRequest>\nURL: %@\nMethod: %@\nRequest Headers:%@\nBody: %@\n\nResponse Status: FAILURE \nError Description: %@",request.URL, request.HTTPMethod, request.allHTTPHeaderFields, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding], error.localizedDescription);
                    
                } else {
                    
                    NSRange truncatedRange = {0, MIN(requestResponse.string.length, 25)};
                    truncatedRange = [requestResponse.string rangeOfComposedCharacterSequencesForRange:truncatedRange];
                    
                    NSLog(@"\n<ThunderRequest>\nURL:    %@\nMethod: %@\nRequest Headers:%@\nBody: %@\n\nResponse Status: %li\nResponse Body: %@\n",request.URL, request.HTTPMethod, request.allHTTPHeaderFields, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding], (long)requestResponse.status, self.truncatesVerboseResponse ? [[requestResponse.string substringWithRange:truncatedRange] stringByAppendingString:@"..."] : requestResponse.string);
                    
                }
                
            }
            
        }] resume];

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

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    CGFloat progress = (float)((float)totalBytesWritten /(float)totalBytesExpectedToWrite);
    
    [self callProgressHandlerForTaskIdentifier:downloadTask.taskIdentifier progress:progress];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    [self callCompletionHandlerForTaskIdentifier:downloadTask.taskIdentifier downloadedFileURL:location downloadError:nil];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{    
    [self callCompletionHandlerForTaskIdentifier:task.taskIdentifier downloadedFileURL:nil downloadError:error];
}

#pragma mark - NSURLSessionDownload completion handling

- (void)addCompletionHandler:(TSCRequestDownloadCompletionHandler)handler progressHandler:(TSCRequestProgressHandler)progress forTaskIdentifier:(NSUInteger)identifier
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

    TSCRequestDownloadCompletionHandler handler = [self.completionHandlerDictionary objectForKey:taskIdentifierString];
    
    if (handler) {
        
        [self.completionHandlerDictionary removeObjectsForKeys:@[taskIdentifierString, taskProgressIdentifierString]];
        
        handler(fileURL, error);
        
    }
}

- (void)callProgressHandlerForTaskIdentifier:(NSUInteger)identifier progress:(CGFloat)progress
{
    NSString *taskProgressIdentifierString = [NSString stringWithFormat:@"%lu-progress", (unsigned long)identifier];
    
    TSCRequestProgressHandler handler = [self.completionHandlerDictionary objectForKey:taskProgressIdentifierString];
    
    if (handler) {
        
        handler(progress);
        
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
        return;
    }
    
    TSCOAuth2Credential *credential = (TSCOAuth2Credential *)[TSCOAuth2Credential retrieveCredentialWithIdentifier:[OAuth2Delegate serviceIdentifier]];
    if (credential) {
        self.sharedRequestCredential = credential;
    }
}

- (void)setSharedRequestCredential:(TSCRequestCredential *)credential andSaveToKeychain:(BOOL)save
{
    _sharedRequestCredential = credential;
    
    if (save) {
        [[credential class] storeCredential:credential withIdentifier: self.OAuth2Delegate ? [self.OAuth2Delegate serviceIdentifier] : [NSString stringWithFormat:@"thundertable.com.threesidedcube-%@", self.sharedBaseURL]];
    }
}

@end
