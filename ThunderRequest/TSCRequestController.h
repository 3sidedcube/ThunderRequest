@import Foundation;

#if TARGET_OS_IPHONE
@import UIKit;
#else

#endif
#import "TSCRequestDefines.h"
#import "TSCOAuth2Manager.h"
#import "TSCRequest.h"

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
 
 IMPORTANT --- TSCRequestController uses NSURLSessions internally, which cause a memory leak due to having a strong reference to their delegate
 when you are done with an instance of TSCRequestController you must call -invalidateAndCancel
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
 A custom queue to dispatch all callbacks from requests onto
 */
@property (nonatomic, assign, nullable) dispatch_queue_t callbackQueue;

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

@end
