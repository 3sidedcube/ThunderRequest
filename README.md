#Thunder Request

[![Build Status](https://travis-ci.org/3sidedcube/iOS-ThunderRequest.svg)](https://travis-ci.org/3sidedcube/iOS-ThunderRequest)

Thunder Request is a Framework used to simplify making web requests.

#Installation

Setting up your app to use Thunder Request is a simple and quick process. ThunderRequest is now built as a framework meaning it is compatible with iOS 8 and above.

+ Drag all included files and folders to a location within your existing project.
+ Add ThunderRequest.framework to your Embedded Binaries.
+ Wherever you want to use ThunderRequest use `@import ThunderRequest` or `import ThunderRequest` if you're using swift.

#OAuth 2.0 Support
OAuth 2.0 support is available via the protocol `<TSCOAuth2Manager>` which when set on `TSCRequestController` will have it's delegate methods called to refresh the user's token when it either expires or a 403 is received by the server.

When OAuth2Delegate is set on `TSCRequestController` any current OAuth2 credentials will be pulled from the user's keychain by the service identifier provided by `-serviceIdentifier` on the delegate.

To register an OAuth2 credential for the first time to the user's keychain, use the method `-setSharedRequestCredential:andSaveToKeychain:` after having set the delegate. This will store the credential to the keychain for later use by the request controller and also set the `sharedRequestCredential` property on the request controller.

If the request controller detects that the `TSCOAuth2Credential` object is expired, or recieves a 403 on a request it will call the method `-reAuthenticateCredential:withCompletion:` to re-authenticate the user before then continuing to make the request (Or re-making) the request.

#Code level documentation
Documentation is available for the entire library in AppleDoc format. This is available in the framework itself or in the [Hosted Version](http://3sidedcube.github.io/iOS-ThunderRequest/)

#License
See [LICENSE.md](LICENSE.md)
