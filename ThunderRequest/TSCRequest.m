//
//  TSCRequest.m
//  ThunderRequest
//
//  Created by Matthew Cheetham on 11/07/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCRequest.h"
#import <CommonCrypto/CommonDigest.h>

@implementation TSCRequest

- (void)prepareForDispatch
{
    if (!self.path) {
        self.path = @"";
    }
    
    self.URL = [self.baseURL URLByAppendingPathComponent:self.path];
    
    if (self.URLParameterDictionary) {
        self.URL = [self TSC_populatedAddressWithBaseAddress:self.URL.absoluteString paramDictionary:self.URLParameterDictionary];
    }
    
    self.HTTPMethod = [self TSC_stringForHTTPMethod:self.requestHTTPMethod];
    self.HTTPBody = [self HTTPBodyWithDictionary:self.bodyParameters];
    [self setValue:[self TSC_contentTypeStringForContentType:self.contentType] forHTTPHeaderField:@"Content-Type"];
    for (NSString *key in [self.requestHeaders allKeys]) {
        [self setValue:self.requestHeaders[key] forHTTPHeaderField:key];
    }
}


#pragma mark - Body building

- (nullable NSData *)HTTPBodyWithDictionary:(NSDictionary *)dictionary
{
    if (dictionary) {
        
        NSError *encodingError;
        NSData *encodedBody = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&encodingError];
        
        if (encodingError) {
            
            return nil;
            
        }
        
        return encodedBody;
        
    }
    
    return nil;
}

#pragma mark - URL placeholder substitution

- (nonnull NSURL *)TSC_populatedAddressWithBaseAddress:(nonnull NSString *)address paramDictionary:(nullable NSDictionary *)parameters
{
    NSMutableString *absoluteAddress = [NSMutableString stringWithString:address];
    
    for (NSString *parameterKey in self.URLParameterDictionary.allKeys) {
        
        NSString *replacementValue = [self TSC_stringValueForObject:self.URLParameterDictionary[parameterKey]];
        NSString *paramFormatKey = [NSString stringWithFormat:@"(:%@)", parameterKey];
        
        [absoluteAddress replaceOccurrencesOfString:paramFormatKey withString:replacementValue options:NSCaseInsensitiveSearch range:NSMakeRange(0, absoluteAddress.length)];
    }
    
    return [NSURL URLWithString:absoluteAddress];
}

- (nullable NSString *)TSC_stringValueForObject:(nonnull NSObject *)object
{
    NSString *string = nil;
    
    if ([object isKindOfClass:[NSString class]]) {
        
        string = (NSString *)object;
        return string;
        
    }
    
    if ([object isKindOfClass:[NSNumber class]]) {
        
        NSNumber *number = (NSNumber *)object;
        
        string = [number stringValue];
        return string;

    }
    
    return nil;
    
}

#pragma mark - ENUM conversion

- (nullable NSString *)TSC_stringForHTTPMethod:(TSCRequestHTTPMethod)HTTPMethod
{
    switch (HTTPMethod) {
        case TSCRequestHTTPMethodGET:
            return @"GET";
        case TSCRequestHTTPMethodPOST:
            return @"POST";
        case TSCRequestHTTPMethodPUT:
            return @"PUT";
        case TSCRequestHTTPMethodDELETE:
            return @"DELETE";
        case TSCRequestHTTPMethodHEAD:
            return @"HEAD";
        default:
            return nil;
            break;
    }
}

- (nonnull NSString *)TSC_contentTypeStringForContentType:(TSCRequestContentType)contentType
{
    switch (contentType) {
        case TSCRequestContentTypeJSON:
            return @"application/json";
        case TSCRequestContentTypeMultipartFormData:
            return [NSString stringWithFormat:@"multipart/form-data; boundary=%@", [self TSC_multipartFormDataBoundaryWithDictionary:self.bodyParameters]];
        case TSCRequestContentTypeImageJPEG:
            return @"image/jpeg";
        case TSCRequestContentTypeImagePNG:
            return @"image/png";
            
        default:
            return @"application/json";
            break;
    }
}

#pragma mark - Multipart form data

- (nonnull NSString *)TSC_multipartFormDataBoundaryWithDictionary:(nonnull NSDictionary *)dictionary
{
    NSString *boundaryHash = [[dictionary description] MD5String];
    NSString *boundary = [NSString stringWithFormat:@"----TSCRequestController%@", boundaryHash];
    
    return boundary;
}

- (nonnull NSData *)TSC_multipartFormDataWithDictionary:(nonnull NSDictionary *)dictionary
{
    NSMutableData *postBody = [NSMutableData new];
    
    NSString *boundary = [self TSC_multipartFormDataBoundaryWithDictionary:dictionary];
    
    NSArray *paramKeys = [dictionary allKeys];
    
    for (NSString *key in paramKeys) {
        
        NSObject *object = dictionary[key];
        
        if ([object isKindOfClass:[NSString class]]) {
            [postBody appendData:[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-   ; name=\"%@\"\r\n\r\n%@\r\n", boundary, key, (NSString *)object] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        if ([object isKindOfClass:[NSData class]]) {
            
            NSString *contentType = [self TSC_contentTypeForImageData:(NSData *)object];
            NSString *fileExtension = [self TSC_fileExtensionForContentType:contentType];
            [postBody appendData:[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"filename.%@\"\r\n", boundary, key, fileExtension] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [postBody appendData:[NSData dataWithData:(NSData *)object]];
            [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
        }
    }
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return postBody;
}

- (nullable NSString *)TSC_contentTypeForImageData:(nonnull NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
            
        case 0x89:
            return @"image/png";
            
        case 0x47:
            return @"image/gif";
            
        case 0x49:
        case 0x4D:
            return @"image/tiff";
            
        case 0x00:
            return @"video/quicktime";
            
        case 0x44:
            return @"text/plain";
    }
    
    return nil;
}

- (nonnull NSString *)TSC_fileExtensionForContentType:(nonnull NSString *)contentType
{
    if([contentType isEqualToString:@"image/jpeg"]){
        return @"jpg";
    }
    if([contentType isEqualToString:@"image/png"]){
        return @"png";
    }
    if([contentType isEqualToString:@"image/gif"]){
        return @"gif";
    }
    if([contentType isEqualToString:@"image/tiff"]){
        return @"tiff";
    }
    if([contentType isEqualToString:@"video/quicktime"]){
        return @"mov";
    }
    if([contentType isEqualToString:@"text/plain"]){
        return @"txt";
    }
    
    return @"jpg";
}
@end

@implementation NSString (MD5)

- (nonnull NSString *)MD5String
{
    const char *ptr = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(ptr, (unsigned int)strlen(ptr), md5Buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end
