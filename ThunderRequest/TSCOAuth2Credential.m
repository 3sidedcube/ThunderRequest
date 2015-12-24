//
//  TSCOAuth2Credential.m
//  ThunderRequest
//
//  Created by Simon Mitchell on 14/09/2015.
//  Copyright © 2015 threesidedcube. All rights reserved.
//

#import "TSCOAuth2Credential.h"

@implementation TSCOAuth2Credential

- (instancetype)initWithAuthorizationToken:(NSString *)authorizationToken refreshToken:(NSString *)refreshToken expiryDate:(NSDate *)expiryDate
{
    if (self = [super initWithAuthorizationToken:authorizationToken]) {
        
        self.refreshToken = refreshToken;
        self.expirationDate = expiryDate;
        self.tokenType = @"Bearer";
    }
    return self;
}

- (instancetype)initWithAuthorizationToken:(NSString *)authorizationToken refreshToken:(NSString *)refreshToken expiryDate:(NSDate *)expiryDate tokenType:(NSString *)tokenType
{
    if (self = [super initWithAuthorizationToken:authorizationToken]) {
        
        self.refreshToken = refreshToken;
        self.expirationDate = expiryDate;
        self.tokenType = tokenType;
    }
    return self;
}

- (BOOL)hasExpired
{
    // Has expired if current date is later in time than the expiry date
    return [[NSDate date] compare:self.expirationDate] == NSOrderedDescending;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.authorizationToken forKey:@"TSCAuthToken"];
    [encoder encodeObject:self.refreshToken forKey:@"TSCRefreshToken"];
    [encoder encodeObject:self.expirationDate forKey:@"TSCExpirationDate"];
    [encoder encodeObject:self.tokenType forKey:@"TSCTokenType"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if((self = [super init])) {
        
        self.authorizationToken = [decoder decodeObjectForKey:@"TSCAuthToken"];
        self.refreshToken = [decoder decodeObjectForKey:@"TSCRefreshToken"];
        self.expirationDate = [decoder decodeObjectForKey:@"TSCExpirationDate"];
        self.tokenType = [decoder decodeObjectForKey:@"TSCTokenType"];
        
        if (!self.tokenType) {
            self.tokenType = @"Bearer";
        }
    }
    return self;
}

@end
