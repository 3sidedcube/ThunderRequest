#import "TSCRequestCredential.h"

NSString * const kTSCAuthServiceName = @"TSCAuthCredential";

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

#pragma mark - 
#pragma mark - Keychain Access

+ (NSMutableDictionary *)keychainDictionaryWithIdentifier:(NSString *)identifier
{
    return [@{
             (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
             (__bridge id)kSecAttrService: kTSCAuthServiceName,
             (__bridge id)kSecAttrAccount: identifier
             } mutableCopy];
}

+ (BOOL)deleteCredentialWithIdentifier:(NSString *)identifier
{
    return (SecItemDelete((__bridge CFDictionaryRef)[self keychainDictionaryWithIdentifier:identifier]) == errSecSuccess);
}

+ (BOOL)storeCredential:(TSCRequestCredential *)credential withIdentifier:(NSString *)identifier
{
    NSMutableDictionary *queryDictionary = [self keychainDictionaryWithIdentifier:identifier];
    
    if (!credential) {
        return [self deleteCredentialWithIdentifier:identifier];
    }
    
    NSMutableDictionary *updateDictionary = [NSMutableDictionary new];
    updateDictionary[(__bridge id)kSecValueData] = [NSKeyedArchiver archivedDataWithRootObject:credential];
    
    OSStatus status;
    
    BOOL exists = ([self retrieveCredentialWithIdentifier:identifier] != nil);
    
    if (exists) {
        
        status = SecItemUpdate((__bridge CFDictionaryRef)queryDictionary, (__bridge CFDictionaryRef)updateDictionary);
        
    } else {
        
        [queryDictionary addEntriesFromDictionary:updateDictionary];
        status = SecItemAdd((__bridge CFDictionaryRef)queryDictionary, NULL);
    }
    
    return (status == errSecSuccess);
}

+ (instancetype)retrieveCredentialWithIdentifier:(NSString *)identifier
{
    NSMutableDictionary *queryDictionary = [self keychainDictionaryWithIdentifier:identifier];
    
    queryDictionary[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    queryDictionary[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    
    CFDataRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, (CFTypeRef *)&result);
    
    return (status != errSecSuccess) ? nil : [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)result];
}

@end
