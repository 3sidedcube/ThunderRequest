//
//  PCRequestResponse.h
//  Demo
//
//  Created by Phillip Caudell on 12/06/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TSCResponseStatus) {
    TSCResponseStatusOK = 200,
    TSCResponseStatusCreated = 201,
    TSCResponseStatusAccepted = 202,
    TSCResponseStatusNonAuthoritativeInformation = 203,
    TSCResponseStatusNoContent = 204,
    TSCResponseStatusBadRequest = 400,
    TSCResponseStatusUnauthorized = 401,
    TSCResponseStatusPaymentRequired = 402,
    TSCResponseStatusForbidden = 403,
    TSCResponseStatusNotFound = 404,
    TSCResponseStatusMethodNotAllowed = 405,
    TSCResponseStatusNotAcceptable = 406,
    TSCResponseStatusInternalServerError = 500,
    TSCResponseStatusNotImplemented = 501,
    TSCResponseStatusBadGateway = 502,
    TSCResponseStatusServiceUnavailable = 503,
};

@interface TSCRequestResponse : NSObject

@property (nonatomic, strong) NSDictionary *responseHeaders;
@property (nonatomic, assign) NSInteger responseStatus;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSHTTPURLResponse *HTTPResponse;

@property (nonatomic, assign) TSCResponseStatus status;
@property (nonatomic, weak) NSArray *array;
@property (nonatomic, weak) NSDictionary *dictionary;
@property (nonatomic, weak) NSString *string;
@property (nonatomic, weak) NSObject *object;

- (id)initWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data;

@end
