//
//  TSCOAuth2Credential.h
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/09/2015.
//  Copyright © 2015 threesidedcube. All rights reserved.
//

#import "TSCRequestCredential.h"

@interface TSCOAuth2Credential : TSCRequestCredential

/**
 Initializes the credentials object.
 @param authorizationToken The authorizationToken to be sent by `TSCRequestController` for authentication requests.
 @param refreshToken The refresh token to be sent back to the authenticating endpoint for certain authentification methods
 @param expiryDate The date upon which the credential will expire for the user
 */
- (instancetype)initWithAuthorizationToken:(NSString *)authorizationToken refreshToken:(NSString *)refreshToken expiryDate:(NSDate *)expiryDate;

/**
 Initializes the credentials object.
 @param authorizationToken The authorizationToken to be sent by `TSCRequestController` for authentication requests.
 @param refreshToken The refresh token to be sent back to the authenticating endpoint for certain authentification methods
 @param expiryDate The date upon which the credential will expire for the user
 @param tokenType The token type of the credential (Often Bearer)
 */
- (instancetype)initWithAuthorizationToken:(NSString *)authorizationToken refreshToken:(NSString *)refreshToken expiryDate:(NSDate *)expiryDate tokenType:(NSString *)tokenType;

/**
 @abstract The date upon which the credential will expire for the user
 @discussion This will determine with some authentication types (Mainly OAuth 2) when Thunder Request will attempt to re-authenticate the user
 */
@property (nonatomic, strong) NSDate *expirationDate;

/**
 @abstract The refresh token to be sent back to the authenticating endpoint for certain authentification methods
 */
@property (nonatomic, copy) NSString *refreshToken;

/**
 @abstract The type of the token
 */
@property (nonatomic, copy) NSString *tokenType;

/**
 @abstract Returns whether the credential has expired
 */
@property (nonatomic, assign, getter=hasExpired, readonly) BOOL expired;

@end
