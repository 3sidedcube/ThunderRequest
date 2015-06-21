//
//  PCRequestCredential.m
//  Demo
//
//  Created by Phillip Caudell on 12/06/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import "TSCRequestCredential.h"

@implementation TSCRequestCredential

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password
{
    self = [super init];
    
    if (self) {
        
        self.username = username;
        self.password = password;
        self.credential = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone];
    }
    
    return self;
}

- (instancetype)initWithAuthorizationToken:(NSString *)authorizationToken
{
    self = [super init];
    
    if (self) {
        self.authorizationToken = authorizationToken;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.password forKey:@"password"];
    [encoder encodeObject:self.authorizationToken forKey:@"authtoken"];
    [encoder encodeObject:self.credential forKey:@"credential"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if((self = [super init])) {
        
        self.username = [decoder decodeObjectForKey:@"username"];
        self.password = [decoder decodeObjectForKey:@"password"];
        self.authorizationToken = [decoder decodeObjectForKey:@"authtoken"];
        self.credential = [decoder decodeObjectForKey:@"credential"];
    }
    return self;
}

@end
