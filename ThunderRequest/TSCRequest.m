//
//  PCRequest.m
//  Demo
//
//  Created by Phillip Caudell on 12/06/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import "TSCRequest.h"
#import <CommonCrypto/CommonDigest.h>

@interface TSCRequest()
{
    NSURLConnection *_connection;
    NSMutableData *_recievedData;
    NSHTTPURLResponse *URLResponse;
}

- (NSURL *)PC_absoluteURL;
- (NSURLRequest *)PC_request;
- (NSString *)PC_address:(NSString *)address withParamDictionary:(NSDictionary *)params;
- (NSString *)PC_address:(NSString *)address withParamObject:(NSObject *)object;
- (NSString *)PC_stringValueWithObject:(NSObject *)object;
- (NSString *)PC_HTTPMethodDescription:(TSCRequestHTTPMethod)HTTPMethod;
- (NSData *)PC_HTTPBodyWithDictionary:(NSDictionary *)dictionary encodeType:(TSCRequestContentType)encodeType;

@end;

@implementation TSCRequest

- (void)start
{
    _request = [self PC_request];
    
    _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
    [_connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_connection start];
    
}

- (void)cancel
{
    [_connection cancel];
}

- (NSURLRequest *)PC_request
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self PC_absoluteURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:[self PC_HTTPMethodDescription:self.HTTPMethod]];
    [request setHTTPBody:[self PC_HTTPBodyWithDictionary:self.bodyParams encodeType:self.contentType]];

    for (NSString *key in [self.requestHeaders allKeys]) {
        [request setValue:self.requestHeaders[key] forHTTPHeaderField:key];
    }
    
    [request setValue:[self PC_contentTypeStringWithContentType:self.contentType] forHTTPHeaderField:@"Content-Type"];
    
    return request;
}

- (NSURL *)PC_absoluteURL
{
    NSString *absoluteAddress = [self.baseURL.absoluteString stringByAppendingFormat:@"/%@", self.path];
    
    if (self.URLParamDictionary) {
        absoluteAddress = [self PC_address:absoluteAddress withParamDictionary:self.URLParamDictionary];
    }
    
    if (self.URLParamObject) {
        
        absoluteAddress = [self PC_address:absoluteAddress withParamObject:self.URLParamObject];
    }
    
    return [NSURL URLWithString:absoluteAddress];
}

- (NSString *)PC_HTTPMethodDescription:(TSCRequestHTTPMethod)HTTPMethod
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

- (NSString *)PC_contentTypeStringWithContentType:(TSCRequestContentType)contentType
{
    switch (contentType) {
        case TSCRequestContentTypeJSON:
            
            return @"application/json";
        case TSCRequestContentTypeMultipartFormData:
            
            return [NSString stringWithFormat:@"multipart/form-data; boundary=%@", [self PC_multipartFormDataBoundaryWithDictionary:self.bodyParams]];
        default:
            
            return @"";
            break;
    }
}

- (NSData *)PC_HTTPBodyWithDictionary:(NSDictionary *)dictionary encodeType:(TSCRequestContentType)encodeType
{
    if (!self.bodyParams) {
        return nil;
    }
    
    if (encodeType == TSCRequestContentTypeJSON) {
        return [self PC_jsonDataWithDictionary:dictionary];
    }
    
    if (encodeType == TSCRequestContentTypeMultipartFormData) {
        return [self PC_multipartFormDataWithDictionary:dictionary];
    }
    
    return nil;
}

- (NSData *)PC_jsonDataWithDictionary:(NSDictionary *)dictionary
{
    return [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
}

- (NSData *)PC_multipartFormDataWithDictionary:(NSDictionary *)dictionary
{
    NSMutableData *postBody = [[NSMutableData alloc] init];
    
    NSString *boundary = [self PC_multipartFormDataBoundaryWithDictionary:dictionary];
    
    NSArray *paramKeys = [dictionary allKeys];
    
    for (NSString *key in paramKeys) {
        
        NSObject *object = [dictionary objectForKey:key];
        
        if ([object isKindOfClass:[NSString class]]) {
            [postBody appendData:[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-   ; name=\"%@\"\r\n\r\n%@\r\n", boundary, key, (NSString *)object] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        if ([object isKindOfClass:[NSData class]]) {
            
            NSString *contentType = [self PC_contentTypeForImageData:(NSData *)object];
            NSString *fileExtension = [self PC_fileExtensionForContentType:contentType];
            [postBody appendData:[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"filename.%@\"\r\n", boundary, key, fileExtension] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [postBody appendData:[NSData dataWithData:(NSData *)object]];
            [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
        }
    }
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return postBody;
}

- (NSString *)PC_multipartFormDataBoundaryWithDictionary:(NSDictionary *)dictionary
{
    NSString *boundaryHash = [[dictionary description] MD5String];
    NSString *boundary = [NSString stringWithFormat:@"----PCRequestKit%@", boundaryHash];
    
    return boundary;
}

- (NSString *)PC_contentTypeForImageData:(NSData *)data
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

- (NSString *)PC_fileExtensionForContentType:(NSString *)contentType
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
    
    return @".jpg";
}

- (NSString *)PC_stringValueWithObject:(NSObject *)object
{
    NSString *string = (NSString *)object;
    
    if ([object isKindOfClass:[NSNumber class]]) {
        string = [(NSNumber *)object stringValue];
    }
    
    return string;
}

- (NSString *)PC_address:(NSString *)address withParamDictionary:(NSDictionary *)params
{
    NSMutableString *absoluteAddress = [NSMutableString stringWithString:address];
    
    for (NSString *paramKey in self.URLParamDictionary.allKeys) {
        
        NSString *replacementValue = [self PC_stringValueWithObject:[self.URLParamDictionary objectForKey:paramKey]];
        NSString *paramFormatKey = [NSString stringWithFormat:@"(:%@)", paramKey];
    
        [absoluteAddress replaceOccurrencesOfString:paramFormatKey withString:replacementValue options:NSCaseInsensitiveSearch range:NSMakeRange(0, absoluteAddress.length)];
    }
    
    return absoluteAddress;
}

- (NSString *)PC_address:(NSString *)address withParamObject:(NSObject *)object
{
    NSMutableString *absoluteAddress = [NSMutableString stringWithString:address];
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"\\(\\:.*\\)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regularExpression matchesInString:absoluteAddress options:0 range:NSMakeRange(0, absoluteAddress.length)];
    
    NSMutableArray *paramKeys = [NSMutableArray array];

    for (NSTextCheckingResult *match in matches) {
        
        NSString *paramFormatKey = [absoluteAddress substringWithRange:match.range];
        [paramKeys addObject:paramFormatKey];
        
    }
    
    for (NSString *paramFormatKey in paramKeys) {
        
        NSString *valueKey = [[paramFormatKey stringByReplacingOccurrencesOfString:@"(:" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
    
        NSString *replacementValue = [self PC_stringValueWithObject:[object valueForKey:valueKey]];
                
        [absoluteAddress replaceOccurrencesOfString:paramFormatKey withString:replacementValue options:NSCaseInsensitiveSearch range:NSMakeRange(0, absoluteAddress.length)];
    }
    
    return absoluteAddress;
}

#pragma mark NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response respondsToSelector:@selector(statusCode)]) {
        URLResponse = (NSHTTPURLResponse *)response;
	}
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    self.response = [[TSCRequestResponse alloc] initWithResponse:URLResponse data:nil];
    self.response.status = httpResponse.statusCode;
    
//    if (self.response.status == 204) {
//        [self connectionDidFinishLoading:_connection];
//    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCRequestDidReceiveResponse" object:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (!_recievedData) {
		_recievedData = [[NSMutableData alloc] initWithCapacity:2048];
	}
	[_recievedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.response.data = _recievedData;
    self.completion(self.response, nil);
    self.isFinished = YES;
    
    if (self.response.status < 200 || self.response.status >= 299) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCRequestServerError" object:self];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.completion(nil, error);
    self.isFinished = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if ([challenge previousFailureCount] == 0) {
        [[challenge sender] useCredential:self.requestCredential.credential forAuthenticationChallenge:challenge];
    }
}

@end

@implementation NSString (MD5)

- (NSString *)MD5String
{
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end