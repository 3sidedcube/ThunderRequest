@import Foundation;

#if TARGET_OS_IPHONE
@import UIKit;
#else

#endif
#import "TSCRequestDefines.h"
#import "TSCOAuth2Manager.h"

@class TSCRequestResponse;
@class TSCRequestCredential;

/**
 A `TSCRequestController` object lets you asynchronously load the contents of a URL with a block returned upon completion.
 
 The `TSCRequestController` object should be added as a property and retained for use with multiple requests.
 Generally one `TSCRequestController` should be initialised and shared per API/Base URL.
 
 To use a `TSCRequestController` do the following:
 
 1. Create a property with the type `TSCRequestController`
 2. Initialise the controller with either the `initWithBaseURL:` or `initWithBaseAddress:` method.
 3. Use any of the GET, POST, PUT, DELETE or HEAD methods to perform an asynchronous web request
 
 */
@interface TSCRequestController : NSObject

typedef void (^TSCRequestCompletionHandler)( TSCRequestResponse * __nullable response, NSError * __nullable error);
typedef void (^TSCRequestTransferCompletionHandler)(NSURL * __nullable fileLocation, NSError * __nullable error);
typedef void (^TSCRequestProgressHandler)(CGFloat progress, NSInteger totalBytes, NSInteger bytesTransferred);

/**
 @abstract The shared Base URL for all requests routed through the controller
 @discussion This is most commonly set using the `initWithBaseURL:` or `initWithBaseAddress:` methods.
 */
@property (nonatomic, strong, nonnull) NSURL *sharedBaseURL;

/**
 @abstract The request controller for making OAuth2 re-authentication requests on
 */
@property (nonatomic, strong, nullable) TSCRequestController *OAuth2RequestController;

/**
 @abstract The shared request headers for all requests routed through the controller
 */
@property (nonatomic, strong, nonnull) NSMutableDictionary *sharedRequestHeaders;

/**
 @abstract The shared request credentials to be used for authorization with any authentication challenge
 */
@property (nonatomic, strong, nullable) TSCRequestCredential *sharedRequestCredential;

/**
 @abstract Can be set to force the request controller to run synchronously
 @discussion This should not be done with requests running on the main thread. It has been added to support requests in OSX Command Line Utilities, be warned. This could lead to issues.
 */
@property (nonatomic, assign) BOOL runSynchronously;

/**
 @abstract Sets the shared request credential and optionally saves it to the keychain
 @param credential The request credential to set `sharedRequestCredential` to
 @param saveToKeychain Whether or not to save the credential object to the user's keychain
 @discussion If a `TSCOAuth2Credential` is stored to the keychain here, is will be pulled from the keychain each time the `OAuth2Delegate` is set on the request controller using the service identifier provided by the delegate object. If OAuth2Delegate is non-nil when this method is called it will be saved under the current delegates service identifier. Otherwise it will be saved under a string appended by `sharedBaseURL`.
 */
- (void)setSharedRequestCredential:(TSCRequestCredential * __nullable)credential andSaveToKeychain:(BOOL)save;

/**
 @abstract The OAuth2 delegate which will respond to OAuth2 unauthenticated responses e.t.c.
 */
@property (nonatomic, assign, nullable) id <TSCOAuth2Manager> OAuth2Delegate;

///---------------------------------------------------------------------------------------
/// @name Initialization
///---------------------------------------------------------------------------------------

/**
 Initializes the request controller.
 @param baseURL The `NSURL` to initialise the controller with. This URL will be used as the base for all requests.
 */
- (nonnull instancetype)initWithBaseURL:(nonnull NSURL *)baseURL;

/**
 Initializes the request controller.
 @param baseAddress The `NSString` to initialise the controller with. This will be converted to a NSURL and be used as the base for all requests.
 */
- (nonnull instancetype)initWithBaseAddress:(nonnull NSString *)baseAddress;

///---------------------------------------------------------------------------------------
/// @name GET requests
///---------------------------------------------------------------------------------------

/**
 Performs a GET request on the base URL.
 @param path The path to be appended to the base URL.
 @param completion The completion block that will be fired once the request has completed.
 @return the request object which was created to perform the required HTTP Request
 */
- (nonnull TSCRequest *)get:(nonnull NSString *)path completion:(nonnull TSCRequestCompletionHandler)completion;

/**
 Performs a GET request on the base URL using the supplied paramater dictionary to build the URL.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param completion The completion block that will be fired once the request has completed.
 @return the request object which was created to perform the required HTTP Request
 */
- (nonnull TSCRequest *)get:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary completion:(nonnull TSCRequestCompletionHandler)completion;

///---------------------------------------------------------------------------------------
/// @name POST requests
///---------------------------------------------------------------------------------------

/**
 Performs a POST request on the base URL using the supplied bodyParams dictionary as the POST body.
 @param path The path to be appended to the base URL.
 @param bodyParams The dictionary used in the POST body.
 @param completion The completion block that will be fired once the request has completed.
 @return the request object which was created to perform the required HTTP Request
 */
- (nonnull TSCRequest *)post:(nonnull NSString *)path bodyParams:(nullable NSDictionary *)bodyParams completion:(nonnull TSCRequestCompletionHandler)completion;

/**
 Performs a POST request on the base URL using the supplied paramater dictionary to build the URL, and bodyParams dictionary as the POST body.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param bodyParams The dictionary used in the POST body.
 @param completion The completion block that will be fired once the request has completed.
 @return the request object which was created to perform the required HTTP Request
 */
- (nonnull TSCRequest *)post:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary bodyParams:(nullable NSDictionary *)bodyParams completion:(nonnull TSCRequestCompletionHandler)completion;

/**
 Performs a POST request on the base URL using the supplied paramater dictionary to build the URL, and bodyParams dictionary as the POST body.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param bodyParams The dictionary used in the POST body.
 @param contentType The type of `TSCRequestContentType` to be used when encoding the request body
 @param completion The completion block that will be fired once the request has completed.
 @return the request object which was created to perform the required HTTP Request
 */
- (nonnull TSCRequest *)post:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary bodyParams:(nullable NSDictionary *)bodyParams contentType:(TSCRequestContentType)contentType completion:(nonnull TSCRequestCompletionHandler)completion;

///---------------------------------------------------------------------------------------
/// @name PUT requests
///---------------------------------------------------------------------------------------

/**
 Performs a PUT request on the base URL using the supplied bodyParams dictionary as the PUT body.
 @param path The path to be appended to the base URL.
 @param bodyParams The dictionary used in the PUT body.
 @param completion The completion block that will be fired once the request has completed.
 @return the request object which was created to perform the required HTTP Request
 */
- (nonnull TSCRequest *)put:(nonnull NSString *)path bodyParams:(nullable NSDictionary *)bodyParams completion:(nonnull TSCRequestCompletionHandler)completion;

/**
 Performs a PUT request on the base URL using the supplied paramater dictionary to build the URL, and bodyParams dictionary as the PUT body.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param bodyParams The dictionary used in the PUT body.
 @param completion The completion block that will be fired once the request has completed.
 @return the request object which was created to perform the required HTTP Request
 */
- (nonnull TSCRequest *)put:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary bodyParams:(nullable NSDictionary *)bodyParams completion:(nonnull TSCRequestCompletionHandler)completion;

/**
 Performs a PUT request on the base URL using the supplied paramater dictionary to build the URL, and bodyParams dictionary as the POST body.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param bodyParams The dictionary used in the PUT body.
 @param contentType The type of `TSCRequestContentType` to be used when encoding the request body
 @param completion The completion block that will be fired once the request has completed.
 @return the request object which was created to perform the required HTTP Request
 */
- (nonnull TSCRequest *)put:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary bodyParams:(nullable NSDictionary *)bodyParams contentType:(TSCRequestContentType)contentType completion:(nonnull TSCRequestCompletionHandler)completion;

///---------------------------------------------------------------------------------------
/// @name DELETE requests
///---------------------------------------------------------------------------------------

/**
 Performs a DELETE request on the base URL.
 @param path The path to be appended to the base URL.
 @param completion The completion block that will be fired once the request has completed.
 @return the request object which was created to perform the required HTTP Request
 */
- (nonnull TSCRequest *)delete:(nonnull NSString *)path completion:(nonnull TSCRequestCompletionHandler)completion;

/**
 Performs a DELETE request on the base URL using the supplied paramater dictionary to build the URL.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param completion The completion block that will be fired once the request has completed.
 @return the request object which was created to perform the required HTTP Request
 */
- (nonnull TSCRequest *)delete:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary completion:(nonnull TSCRequestCompletionHandler)completion;

///---------------------------------------------------------------------------------------
/// @name HEAD requests
///---------------------------------------------------------------------------------------

/**
 Performs a HEAD request on the base URL using the supplied paramater dictionary to build the URL.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param completion The completion block that will be fired once the request has completed.
 @return the request object which was created to perform the required HTTP Request
 */
- (nonnull TSCRequest *)head:(nonnull NSString *)path withURLParamDictionary:(nullable NSDictionary *)URLParamDictionary completion:(nonnull TSCRequestCompletionHandler)completion;

///---------------------------------------------------------------------------------------
/// @name Download requests
///---------------------------------------------------------------------------------------

/**
Performs a file download task using the base url and given path component.
@param path The path to be appended to the base URL
@param progress The block to be called with progress information during the download
@param completion The completion block that will be fired once the request has completed
*/
- (void)downloadFileWithPath:(nonnull NSString *)path progress:(nullable TSCRequestProgressHandler)progress completion:(nonnull TSCRequestTransferCompletionHandler)completion;


///---------------------------------------------------------------------------------------
/// @name Upload requests
///---------------------------------------------------------------------------------------

/**
 Performs a file upload task using the base url and given path component.
 @param imageData The NSData of an image to upload
 @param path The path to be appended to the base URL
 @param progress The block to be called with progress information during the download
 @param completion The completion block that will be fired once the request has completed
 */
- (void)uploadFileData:(nonnull NSData *)fileData toPath:(nonnull NSString *)path progress:(nullable TSCRequestProgressHandler)progress completion:(nonnull TSCRequestTransferCompletionHandler)completion;

/**
 Performs a file upload task using the base url and given path component.
 @param imageData The NSData of an image to upload
 @param path The path to be appended to the base URL
 @param contentType The content type of the upload
 @param progress The block to be called with progress information during the download
 @param completion The completion block that will be fired once the request has completed
 */
- (void)uploadFileData:(nonnull NSData *)fileData toPath:(nonnull NSString *)path contentType:(TSCRequestContentType)type progress:(nullable TSCRequestProgressHandler)progress completion:(nonnull TSCRequestTransferCompletionHandler)completion;

/**
 Performs a file upload task using the base url and given path component.
 @param path The NSData of an image to upload
 @param path The path to be appended to the base URL
 @param progress The block to be called with progress information during the download
 @param completion The completion block that will be fired once the request has completed
 */
- (void)uploadFileFromPath:(nonnull NSString *)filePath toPath:(nonnull NSString *)path progress:(nullable TSCRequestProgressHandler)progress completion:(nonnull TSCRequestTransferCompletionHandler)completion;

/**
 Performs a file upload task using the base url and given path component.
 @param bodyParams The NSDictionary of an object to upload
 @param path The path to be appended to the base URL
 @param contentType The content type of the upload
 @param progress The block to be called with progress information during the download
 @param completion The completion block that will be fired once the request has completed
 */
- (void)uploadBodyParams:(nullable NSDictionary *)bodyParams toPath:(nonnull NSString *)path contentType:(TSCRequestContentType)type progress:(nullable TSCRequestProgressHandler)progress completion:(nonnull TSCRequestTransferCompletionHandler)completion;

@end
