//
//  PCRequestResponse.h
//  Demo
//
//  Created by Phillip Caudell on 12/06/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import <Foundation/Foundation.h>

/** A list of HTTP response codes returned in `TSCRequestResponse` */
typedef NS_ENUM(NSInteger, TSCResponseStatus) {
    /** The request was successful */
    TSCResponseStatusOK = 200,
    /** The request has been fulfilled and resulted in a new resource being created */
    TSCResponseStatusCreated = 201,
    /** The request has been accepted for processing, but the processing has not been completed. */
    TSCResponseStatusAccepted = 202,
    /** The server successfully processed the request, but is returning information that may be from another source */
    TSCResponseStatusNonAuthoritativeInformation = 203,
    /** The server successfully processed the request, but is not returning any content. Usually used as a response to a successful delete request */
    TSCResponseStatusNoContent = 204,
    /** The request cannot be fulfilled due to bad syntax. */
    TSCResponseStatusBadRequest = 400,
    /** Similar to `TSCResponseStatusForbiden`, but specifically for use when authentication is required and has failed or has not yet been provided */
    TSCResponseStatusUnauthorized = 401,
    /** Reserved for future use. */
    TSCResponseStatusPaymentRequired = 402,
    /** The request was a valid request, but the server is refusing to respond to it. Unlike a `TSCResponseStatusUnauthorized`, authenticating will make no difference */
    TSCResponseStatusForbidden = 403,
    /** The requested resource could not be found but may be available again in the future */
    TSCResponseStatusNotFound = 404,
    /** A request was made of a resource using a request method not supported by that resource */
    TSCResponseStatusMethodNotAllowed = 405,
    /** The requested resource is only capable of generating content not acceptable according to the Accept headers sent in the request. */
    TSCResponseStatusNotAcceptable = 406,
    /** A generic error message, given when an unexpected condition was encountered and no more specific message is suitable. */
    TSCResponseStatusInternalServerError = 500,
    /** The server either does not recognize the request method, or it lacks the ability to fulfil the request. */
    TSCResponseStatusNotImplemented = 501,
    /** The server was acting as a gateway or proxy and received an invalid response from the upstream server. */
    TSCResponseStatusBadGateway = 502,
    /** The server is currently unavailable (because it is overloaded or down for maintenance). */
    TSCResponseStatusServiceUnavailable = 503,
};

/**
 A TSCRequestResponse object encapsulated various properties to describe the response the server after executing a `TSCRequest`.
 */
@interface TSCRequestResponse : NSObject

/**
 @abstract HTTP Headers returned by the remote server in response to the request
 */
@property (nonatomic, strong) NSDictionary *responseHeaders;

/**
 @abstract The integer value of the HTTP status code returned by the remote server
 */
@property (nonatomic, assign) NSInteger responseStatus;

/**
 @abstract The NSData value of the information returned from the request
 */
@property (nonatomic, strong) NSData *data;

/**
 @abstract The `NSHTTPURLResponse` object returned by the `NSURLRequest`
 */
@property (nonatomic, strong) NSHTTPURLResponse *HTTPResponse;

/**
 @abstract The `TSCResponseStatus` code returned by the remote server
 */
@property (nonatomic, assign) TSCResponseStatus status;

/**
 @abstract An `NSArray` representation of the data returned from the server
 */
@property (nonatomic, weak) NSArray *array;

/**
 @abstract An `NSDictionary` representation of the data returned from the server
 */
@property (nonatomic, weak) NSDictionary *dictionary;

/**
 @abstract An `NSString` representation of the data returned from the server
 */
@property (nonatomic, copy) NSString *string;

/**
 @abstract An `NSObject` representation of the data returned from the server
 */
@property (nonatomic, weak) NSObject *object;

///---------------------------------------------------------------------------------------
/// @name Initialization
///---------------------------------------------------------------------------------------

/**
 Initializes the response object. Generally you will not need to call this initializer manually
 @param response The `NSHTTPURLResponse` returned by the `NSURLRequest`
 @param data The data returned by the `NSURLRequest`
 */
- (id)initWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data;

@end
