#import <Foundation/Foundation.h>
#import "TSCOAuth2Credential.h"

typedef void (^TSCOAuthAuthenticateCompletion)(TSCOAuth2Credential * __nullable credential, NSError * __nullable error, BOOL saveToKeychain);

@protocol TSCOAuth2Manager <NSObject>

- (void)authenticateWithCompletion:(nonnull TSCOAuthAuthenticateCompletion)completion;

- (void)reAuthenticateWithCompletion:(nonnull TSCOAuthAuthenticateCompletion)completion;

- (nullable NSString *)serviceIdentifier;

@end
