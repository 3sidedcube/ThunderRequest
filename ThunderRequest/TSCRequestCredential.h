#import <Foundation/Foundation.h>

/**
 A TSCRequestResponse object is used for definining authentication credentials to be used for all requests on a TSCRequestController
 */
@interface TSCRequestCredential : NSObject

/**
 @abstract The username to be sent by `TSCRequestController` for authentication requests
 */
@property (nonatomic, copy) NSString *username;

/**
 @abstract The password to be sent by `TSCRequestController` for authentication requests
 */
@property (nonatomic, copy) NSString *password;

/**
 @abstract The authorisation token to be sent by `TSCRequestController` for authentication requests
 */
@property (nonatomic, copy) NSString *authorizationToken;

/**
 @abstract The credential created using the `username`, `password` and/or `authorizationToken` credentials
 @discussion The credential will be created after initialising this object using `initWithUsername:password` or `initWithAuthorizationToken`
 */
@property (nonatomic, strong) NSURLCredential *credential;

///---------------------------------------------------------------------------------------
/// @name Initialization
///---------------------------------------------------------------------------------------

/**
 Initializes the credentials object.
 @param username The username to be sent by `TSCRequestController` for authentication requests.
 @param password The password to be sent by `TSCRequestController` for authentication requests
 */
- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password;

/**
 Initializes the credentials object.
 @param authorizationToken The authorizationToken to be sent by `TSCRequestController` for authentication requests.
 */
- (instancetype)initWithAuthorizationToken:(NSString *)authorizationToken;

@end
