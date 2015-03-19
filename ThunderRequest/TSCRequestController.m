//
//  PCRequestController.m
//  Demo
//
//  Created by Phillip Caudell on 12/06/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import "TSCRequestController.h"

@interface TSCRequestController()
{
    NSOperationQueue *_requestQueue;
}

- (TSCRequest *)PC_baseRequest;

@end

@implementation TSCRequestController

- (id)initWithBaseURL:(NSURL *)baseURL
{
    self = [super init];
    
    if (self) {
        
        self.sharedBaseURL = baseURL;
        self.sharedContentType = TSCRequestContentTypeJSON;
        self.sharedRequestHeaders = [NSMutableDictionary dictionary];
                
        _requestQueue = [[NSOperationQueue alloc] init];
        
    }
    
    return self;
}

- (id)initWithBaseAddress:(NSString *)baseAddress
{
    return [self initWithBaseURL:[NSURL URLWithString:baseAddress]];
}

- (TSCRequest *)PC_baseRequest
{
    TSCRequest *request = [[TSCRequest alloc] init];
    request.baseURL = self.sharedBaseURL;
    request.contentType = self.sharedContentType;
    request.requestHeaders = self.sharedRequestHeaders;
    request.requestCredential = self.sharedRequestCredential;
    
    return request;
}

- (void)get:(NSString *)path completion:(TSCRequestCompletionHandler)completion
{
    [self get:path withURLParamDictionary:nil completion:completion];
}

- (void)get:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary completion:(TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [self PC_baseRequest];
    request.HTTPMethod = TSCRequestHTTPMethodGET;
    request.path = path;
    request.URLParamDictionary = URLParamDictionary;
    request.completion = completion;
    request.isReady = YES;
    [_requestQueue addOperation:request];
}

- (void)get:(NSString *)path withURLParamObject:(NSObject *)URLParamObject completion:(TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [self PC_baseRequest];
    request.HTTPMethod = TSCRequestHTTPMethodGET;
    request.path = path;
    request.URLParamObject = URLParamObject;
    request.completion = completion;
    request.isReady = YES;
    [_requestQueue addOperation:request];
}

- (void)post:(NSString *)path bodyParams:(NSDictionary *)bodyParams completion:(TSCRequestCompletionHandler)completion
{
    [self post:path withURLParamDictionary:nil bodyParams:bodyParams completion:completion];
}

- (void)post:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary bodyParams:(NSDictionary *)bodyParams completion:(TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [self PC_baseRequest];
    request.HTTPMethod = TSCRequestHTTPMethodPOST;
    request.path = path;
    request.URLParamDictionary = URLParamDictionary;
    request.bodyParams = bodyParams;
    request.completion = completion;
    request.isReady = YES;
    [_requestQueue addOperation:request];
}

- (void)post:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary bodyParams:(NSDictionary *)bodyParams contentType:(TSCRequestContentType)contentType completion:(TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [self PC_baseRequest];
    request.HTTPMethod = TSCRequestHTTPMethodPOST;
    request.path = path;
    request.URLParamDictionary = URLParamDictionary;
    request.bodyParams = bodyParams;
    request.completion = completion;
    request.contentType = contentType;
    request.isReady = YES;
    [_requestQueue addOperation:request];
}

- (void)put:(NSString *)path bodyParams:(NSDictionary *)bodyParams completion:(TSCRequestCompletionHandler)completion
{
    [self put:path withURLParamDictionary:nil bodyParams:bodyParams completion:completion];
}

- (void)put:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary bodyParams:(NSDictionary *)bodyParams completion:(TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [self PC_baseRequest];
    request.HTTPMethod = TSCRequestHTTPMethodPUT;
    request.path = path;
    request.URLParamDictionary = URLParamDictionary;
    request.bodyParams = bodyParams;
    request.completion = completion;
    request.isReady = YES;
    [_requestQueue addOperation:request];
}

- (void)put:(NSString *)path withURLParamObject:(NSDictionary *)URLParamObject bodyParams:(NSDictionary *)bodyParams completion:(TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [self PC_baseRequest];
    request.HTTPMethod = TSCRequestHTTPMethodPUT;
    request.path = path;
    request.URLParamObject = URLParamObject;
    request.bodyParams = bodyParams;
    request.completion = completion;
    request.isReady = YES;
    [_requestQueue addOperation:request];
}

- (void)delete:(NSString *)path completion:(TSCRequestCompletionHandler)completion
{
    [self delete:path withURLParamDictionary:nil completion:completion];
}

- (void)delete:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary completion:(TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [self PC_baseRequest];
    request.HTTPMethod = TSCRequestHTTPMethodDELETE;
    request.path = path;
    request.URLParamDictionary = URLParamDictionary;
    request.completion = completion;
    request.isReady = YES;
    [_requestQueue addOperation:request];
}

- (void)delete:(NSString *)path withURLParamObject:(NSObject *)URLParamObject completion:(TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [self PC_baseRequest];
    request.HTTPMethod = TSCRequestHTTPMethodDELETE;
    request.path = path;
    request.URLParamObject = URLParamObject;
    request.completion = completion;
    request.isReady = YES;
    [_requestQueue addOperation:request];
}

- (void)head:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary completion:(TSCRequestCompletionHandler)completion
{
    TSCRequest *request = [self PC_baseRequest];
    request.HTTPMethod = TSCRequestHTTPMethodHEAD;
    request.path = path;
    request.URLParamDictionary = URLParamDictionary;
    request.completion = completion;
    request.isReady = YES;
    [_requestQueue addOperation:request];
}

@end
