//
//  PCRequestCredential.h
//  Demo
//
//  Created by Phillip Caudell on 12/06/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCRequestCredential : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *authorizationToken;

@property (nonatomic, strong) NSURLCredential *credential;

- (id)initWithUsername:(NSString *)username password:(NSString *)password;
- (id)initWithAuthorizationToken:(NSString *)authorizationToken;

@end
