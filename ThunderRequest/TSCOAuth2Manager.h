#import <Foundation/Foundation.h>
@class TSCOAuth2Credential;
@class TSCRequest;

typedef void (^TSCOAuthAuthenticateCompletion)(TSCOAuth2Credential * __nullable credential, NSError * __nullable error, BOOL saveToKeychain);

/**
 TSCOAuth2Manager is a protocol which will be used to generate and re-authenticate OAuth2 credentials for a particular instance of `TSCRequestController`
 
 @discussion To perform the initial authentication call your own authenticateWithCompletion implementation and then save the credential object which you would otherwise return in the completion block to the Keychain using `TSCOAuth2Credential`'s method `+storeCredential:withIdentifier:`. Once you have stored the credential in the keychain all requests will check that it hasn't expired before making the request.
 
 Setting the `TSCRequestController`'s sharedRequestCredential using `-setSharedRequestCredential:andSaveToKeychain:` with true will also achieve the same effect as saving the credential directly to the keychain
 */
@protocol TSCOAuth2Manager <NSObject>


@optional

/**
 This method will be called if a request is made without a TSCOAuthCredential object having been saved to the keychain under -serviceIdentifier
 @param completion The completion block which should be called when the user has been authenticated
 */
- (void)authenticateWithCompletion:(nonnull TSCOAuthAuthenticateCompletion)completion;

@required

/**
 This method will be called if a request is made with an expired token, or if we recieve a 403 challenge from a particular request
 @param credential The credential which should be used in the refresh process
 @param completion The completion block which should be called when the user's credential has been refreshed
 @warning Because this is an OAuth2 flow any authentication requests made within this method must be done on a seperate request controller to all other requests, otherwise we will end up queueing the re-authentication request until it completes, which would result in it never completing and thus the request controller would queue every request forever!
 */
- (void)reAuthenticateCredential:(nullable TSCOAuth2Credential *)credential withCompletion:(nonnull TSCOAuthAuthenticateCompletion)completion;

/**
 This should return the service identifier for the OAuth flow, which the credentials object will be saved into the keychain under
 */
- (nonnull NSString *)serviceIdentifier;

@end
