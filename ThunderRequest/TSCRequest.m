#import "TSCRequest.h"
#import "NSDictionary+URLEncoding.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSDictionary+URLEncoding.h"

#if TARGET_OS_IPHONE
@import UIKit;
#else
#import <AppKit/AppKit.h>
#endif

@implementation TSCRequest

- (void)prepareForDispatch
{
    if (!self.path) {
        self.path = @"";
    }
    
    self.URL = [NSURL URLWithString:self.path relativeToURL:self.baseURL];
    
    if (self.URLParameterDictionary) {
        self.URL = [self TSC_populatedAddressWithBaseAddress:self.URL.absoluteString paramDictionary:self.URLParameterDictionary];
    }
    
    self.HTTPMethod = [self stringForHTTPMethod:self.requestHTTPMethod];
    self.HTTPBody = [self HTTPBodyWithDictionary:self.bodyParameters];
    [self setValue:[self TSC_contentTypeStringForContentType:self.contentType] forHTTPHeaderField:@"Content-Type"];
    [self.requestHeaders setValue:[self TSC_contentTypeStringForContentType:self.contentType] forKey:@"Content-Type"];
    for (NSString *key in [self.requestHeaders allKeys]) {
        [self setValue:self.requestHeaders[key] forHTTPHeaderField:key];
    }
}


#pragma mark - Body building

- (nullable NSData *)HTTPBodyWithDictionary:(NSDictionary *)dictionary
{
    if (dictionary) {
        
        switch (self.contentType) {
            case TSCRequestContentTypeJSON:
                return [self TSC_JSONDataWithDictionary:dictionary];
                break;
            case TSCRequestContentTypeFormURLEncoded:
                return [dictionary urlEncodedFormData];
                break;
            case TSCRequestContentTypeMultipartFormData:
                return [self TSC_multipartFormDataWithDictionary:dictionary];
                break;
            case TSCRequestContentTypeXMLPlist:
                return [self TSC_plistDataWithDictionary:dictionary];
                break;
            case TSCRequestContentTypeImageJPEG:
                return [self TSC_jpgDataWithDictionary:dictionary];
                break;
            case TSCRequestContentTypeImagePNG:
                return [self TSC_pngDataWithDictionary:dictionary];
                break;
            default:
                break;
        }
    }
    
    return nil;
}

#pragma mark - PNG Encoding

#if TARGET_OS_IPHONE
- (NSData *)TSC_pngDataWithDictionary:(NSDictionary *)dictionary
{
    __block NSData *data;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSData class]]) {
            
            data = obj;
            *stop = true;
        } else if ([obj isKindOfClass:[UIImage class]]) {
            
            data = UIImagePNGRepresentation(obj);
            *stop = true;
        }
    }];
    return data;
}
#else
- (NSData *)TSC_pngDataWithDictionary:(NSDictionary *)dictionary
{
    __block NSData *data;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSData class]]) {
            
            data = obj;
            *stop = true;
        } else if ([obj isKindOfClass:[NSImage class]]) {
            
            //            data = UIImagePNGRepresentation(obj);
            *stop = true;
        }
    }];
    return data;
}
#endif


#pragma mark - JPEG Encoding

#if TARGET_OS_IPHONE
- (nullable NSData *)TSC_jpgDataWithDictionary:(NSDictionary *)dictionary
{
    __block NSData *data;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[UIImage class]]) {
            
            data = obj;
            *stop = true;
        } else if ([obj isKindOfClass:[UIImage class]]) {
            
            data = UIImageJPEGRepresentation(obj, 2.0);
            *stop = true;
        }
    }];
    return data;
}
#else
- (nullable NSData *)TSC_jpgDataWithDictionary:(NSDictionary *)dictionary
{
    __block NSData *data;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSData class]]) {
            
            data = obj;
            *stop = true;
        } else if ([obj isKindOfClass:[NSImage class]]) {
            
            NSBitmapImageRep *imageRep = [[obj representations] objectAtIndex:0];
            data = [imageRep representationUsingType:NSJPEGFileType properties:nil];
            *stop = true;
        }
    }];
    return data;
}
#endif


#pragma mark - XML Plist Encoding

- (nullable NSData *)TSC_plistDataWithDictionary:(NSDictionary *)dictionary
{
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    return data;
}

#pragma mark - JSON Encoding

- (nullable NSData *)TSC_JSONDataWithDictionary:(NSDictionary *)dictionary
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

- (nullable NSString *)stringForHTTPMethod:(TSCRequestHTTPMethod)HTTPMethod
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
            break;
        case TSCRequestContentTypeMultipartFormData:
            return [NSString stringWithFormat:@"multipart/form-data; boundary=%@", [self TSC_multipartFormDataBoundaryWithDictionary:self.bodyParameters]];
            break;
        case TSCRequestContentTypeImageJPEG:
            return @"image/jpeg";
            break;
        case TSCRequestContentTypeImagePNG:
            return @"image/png";
            break;
        case TSCRequestContentTypeFormURLEncoded:
            return @"application/x-www-form-urlencoded";
            break;
        case TSCRequestContentTypeXMLPlist:
            return @"text/x-xml-plist";
            break;
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
    
    NSArray *paramKeys = [dictionary allKeys];
    
    NSString *boundary = [self TSC_multipartFormDataBoundaryWithDictionary:dictionary];
    
    for (NSString *key in paramKeys) {
        
        NSObject *object = dictionary[key];
        [postBody appendData:[self TSC_multipartDataForElement:object key:key boundary:boundary]];
        
    }
    
    return postBody;
}

- (NSData *)TSC_dataForObject:(NSObject *)object
{
    if ([object isKindOfClass:[NSData class]]) {
        return (NSData *)object;
    }
    
#if TARGET_OS_IPHONE
    if ([object isKindOfClass:[UIImage class]]) {
        return UIImageJPEGRepresentation((UIImage *)object, 1.0);
    }
#else
    if ([object isKindOfClass:[NSImage class]]) {
        
        NSBitmapImageRep *imageRep = [[(NSImage *)object representations] objectAtIndex:0];
        return [imageRep representationUsingType:NSJPEGFileType properties:nil];
    }
#endif
    
    return nil;
}

- (NSData *)TSC_multipartDataForElement:(NSObject *)object key:(NSString *)key boundary:(NSString *)boundary
{
    boundary = [NSString stringWithFormat:@"--%@",boundary];
    
    if ([object isKindOfClass:[NSString class]]) {
        return [[NSString stringWithFormat:@"%@\r\nContent-Disposition: form-   ; name=\"%@\"\r\n%@\r\n", boundary, key, (NSString *)object] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSObject *addObject = object;
    if ([self TSC_dataForObject:object]) {
        addObject = [self TSC_dataForObject:object];
    }
    
    if ([addObject isKindOfClass:[NSData class]]) {
        
        NSMutableData *data = [NSMutableData new];
        
        NSString *contentType = [self TSC_contentTypeForImageData:(NSData *)object];
        NSString *fileExtension = [self TSC_fileExtensionForContentType:contentType];
        [data appendData:[[NSString stringWithFormat:@"%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"filename.%@\"\r\n", boundary, key, fileExtension] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [data appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [data appendData:[NSData dataWithData:(NSData *)object]];
        [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[boundary dataUsingEncoding:NSUTF8StringEncoding]];
        
        return data;
    }
    
    if ([addObject isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dictionary = (NSDictionary *)object;
        
        if (dictionary[TSCMultipartFormDataDataKey] && [self TSC_dataForObject:dictionary[TSCMultipartFormDataDataKey]]) {
            
            NSData *data = [self TSC_dataForObject:dictionary[TSCMultipartFormDataDataKey]];
            NSMutableData *returnData = [NSMutableData new];
                        
            NSString *contentType = [self TSC_contentTypeForImageData:data];
            NSString *fileExtension = [self TSC_fileExtensionForContentType:contentType];
            
            NSString *dispositionString = [NSString stringWithFormat:@"%@\r\nContent-Disposition: %@;", boundary, dictionary[TSCMultipartFormDataDispositionKey] ? : @"form-data"];
            
            dispositionString = [dispositionString stringByAppendingFormat:@" name=\"%@\";",dictionary[TSCMultipartFormDataNameKey] ? : key];
            
            dispositionString = [dispositionString stringByAppendingFormat:@" filename=\"%@.%@\"\r\n", dictionary[TSCMultipartFormDataFilenameKey] ? : key, fileExtension];
            
            [returnData appendData:[dispositionString dataUsingEncoding:NSUTF8StringEncoding]];
            
            [returnData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [returnData appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [returnData appendData:data];
            [returnData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [returnData appendData:[[NSString stringWithFormat:@"%@",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            return returnData;
        }
    }

    return nil;
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
