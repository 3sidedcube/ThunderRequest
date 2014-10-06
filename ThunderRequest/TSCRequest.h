//
//  PCRequest.h
//  Demo
//
//  Created by Phillip Caudell on 12/06/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSCRequestResponse.h"
#import "TSCRequestCredential.h"

typedef enum {
    TSCRequestHTTPMethodGET = 0,
    TSCRequestHTTPMethodPOST = 1,
    TSCRequestHTTPMethodPUT = 2,
    TSCRequestHTTPMethodDELETE = 3,
    TSCRequestHTTPMethodHEAD = 4
} TSCRequestHTTPMethod;

typedef enum {
    TSCRequestContentTypeFormURLEncoded = 1,
    TSCRequestContentTypeJSON = 2,
    TSCRequestContentTypeMultipartFormData = 3
} TSCRequestContentType;

typedef void (^TSCRequestCompletionHandler)(TSCRequestResponse *response, NSError *error);

@interface TSCRequest : NSOperation

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSDictionary *URLParamDictionary;
@property (nonatomic, strong) NSObject *URLParamObject;
@property (nonatomic, strong) NSDictionary *bodyParams;
@property (nonatomic, strong) NSDictionary *requestHeaders;
@property (nonatomic, assign) TSCRequestHTTPMethod HTTPMethod;
@property (nonatomic, assign) TSCRequestContentType contentType;
@property (nonatomic, strong) TSCRequestCompletionHandler completion;
@property (nonatomic, strong) TSCRequestCredential *requestCredential;
@property (nonatomic, strong) TSCRequestResponse *response;
@property (nonatomic, readonly) NSURLRequest *request;

@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, assign) BOOL isCanceled;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isConcurrent;

- (void)start;
- (void)cancel;
- (NSString *)PC_HTTPMethodDescription:(TSCRequestHTTPMethod)HTTPMethod;

@end

@interface NSString (MD5)

- (NSString *)MD5String;

@end
