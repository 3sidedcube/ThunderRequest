#import "TSCRequest.h"
#import "NSDictionary+URLEncoding.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSDictionary+URLEncoding.h"

#if TARGET_OS_IPHONE
@import UIKit;
#else
#import <AppKit/AppKit.h>
#endif

@import os.log;
static os_log_t request_log;

@implementation TSCRequest

+ (void)initialize {
	request_log = os_log_create("com.threesidedcube.ThunderRequest", "TSCRequest");
}

- (void)prepareForDispatch
{
    if (!self.path) {
        self.path = @"";
    }
    
    if (self.baseURL) {
        self.URL = [NSURL URLWithString:self.path relativeToURL:self.baseURL];
    } else {
        self.URL = [NSURL URLWithString:self.path];
    }
    
    if (self.URLParameterDictionary) {
        self.URL = [self TSC_populatedAddressWithBaseAddress:self.URL.absoluteString paramDictionary:self.URLParameterDictionary];
    }
    
    self.HTTPMethod = [self stringForHTTPMethod:self.requestHTTPMethod];
    self.HTTPBody = [self HTTPBodyWithDictionary:self.bodyParameters];
	
	// We don't set the content-type header for GET requests as they shouldn't be sending data
	// and some APIs will error if you provide a Content-Type with no data!
	if (self.HTTPMethod != TSCRequestHTTPMethodGET && self.HTTPBody) {
		[self setValue:[self TSC_contentTypeStringForContentType:self.contentType] forHTTPHeaderField:@"Content-Type"];
		[self.requestHeaders setValue:[self TSC_contentTypeStringForContentType:self.contentType] forKey:@"Content-Type"];
	}
	
	if (self.HTTPMethod == TSCRequestHTTPMethodGET && self.HTTPBody) {
		os_log_error(request_log, "Invalid request to: %@. Should not be sending a GET request with a non-nil body", self.URL.absoluteString);
	}
	
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
            
            NSBitmapImageRep *imageRep = (NSBitmapImageRep *)[[obj representations] objectAtIndex:0];
            data = [imageRep representationUsingType:NSJPEGFileType properties:@{}];
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
        case TSCRequestHTTPMethodPATCH:
            return @"PATCH";
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
        case TSCRequestContentTypeURLArguments:
            return @"text/x-url-arguments";
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


@end
