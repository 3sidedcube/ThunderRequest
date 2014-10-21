//
//  PCRequestCredential.h
//  Demo
//
//  Created by Phillip Caudell on 12/06/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCRequestCredential : NSObject

/**
 @abstract The username to be sent by `TSCRequestController` for authentication requests
 */
@property (nonatomic, strong) NSString *username;

/**
 @abstract The password to be sent by `TSCRequestController` for authentication requests
 */
@property (nonatomic, strong) NSString *password;

/**
 @abstract The authorisation token to be sent by `TSCRequestController` for authentication requests
 */
@property (nonatomic, strong) NSString *authorizationToken;

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
- (id)initWithUsername:(NSString *)username password:(NSString *)password;

/**
 Initializes the credentials object.
 @param authorizationToken The authorizationToken to be sent by `TSCRequestController` for authentication requests.
 */
- (id)initWithAuthorizationToken:(NSString *)authorizationToken;

@end
