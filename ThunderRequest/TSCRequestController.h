//
//  PCRequestController.h
//  Demo
//
//  Created by Phillip Caudell on 12/06/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSCRequest.h"

/**
 A `TSCRequestController` object lets you asynchronously load the contents of a URL with a block returned upon completion.
 
 The `TSCRequestController` object should be added as a property and retained for use with multiple requests.
 Generally one `TSCRequestController` should be initialised and shared per API/Base URL.
 
 To use a `TSCRequestController` do the following:
 
 1. Create a property with the type `TSCRequestController`
 2. Initialise the controller with either the `initWithBaseURL:` or `initWithBaseAddress:` method.
 3. Use any of the GET, POST, PUT, DELETE or HEAD methods to perform an asynchronous web request
 
 */
@interface TSCRequestController : NSObject

/**
 @abstract The shared Base URL for all requests routed through the controller
 @discussion This is most commonly set using the `initWithBaseURL:` or `initWithBaseAddress:` methods.
 */
@property (nonatomic, strong) NSURL *sharedBaseURL;

/**
 @abstract The shared request headers for all requests routed through the controller
 */
@property (nonatomic, strong) NSMutableDictionary *sharedRequestHeaders;

/**
 @abstract The shared content type for all requests routed through the controller
 */
@property (nonatomic, assign) TSCRequestContentType sharedContentType;

/**
 @abstract The shared request credentials for all requests routed through the controller
 */
@property (nonatomic, strong) TSCRequestCredential *sharedRequestCredential;

///---------------------------------------------------------------------------------------
/// @name Initialization
///---------------------------------------------------------------------------------------

/**
 Initializes the request controller.
 @param baseURL The `NSURL` to initialise the controller with. This URL will be used as the base for all requests.
 */
- (id)initWithBaseURL:(NSURL *)baseURL;

/**
 Initializes the request controller.
 @param baseAddress The `NSString` to initialise the controller with. This will be converted to a NSURL and be used as the base for all requests.
 */
- (id)initWithBaseAddress:(NSString *)baseAddress;

///---------------------------------------------------------------------------------------
/// @name GET requests
///---------------------------------------------------------------------------------------

/**
 Performs a GET request on the base URL.
 @param path The path to be appended to the base URL.
 @param completion The completion block that will be fired once the request has completed.
 */
- (void)get:(NSString *)path completion:(TSCRequestCompletionHandler)completion;

/**
 Performs a GET request on the base URL using the supplied paramater dictionary to build the URL.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param completion The completion block that will be fired once the request has completed.
 */
- (void)get:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary completion:(TSCRequestCompletionHandler)completion;

///---------------------------------------------------------------------------------------
/// @name POST requests
///---------------------------------------------------------------------------------------

/**
 Performs a POST request on the base URL using the supplied bodyParams dictionary as the POST body.
 @param path The path to be appended to the base URL.
 @param bodyParams The dictionary used in the POST body.
 @param completion The completion block that will be fired once the request has completed.
 */
- (void)post:(NSString *)path bodyParams:(NSDictionary *)bodyParams completion:(TSCRequestCompletionHandler)completion;

/**
 Performs a POST request on the base URL using the supplied paramater dictionary to build the URL, and bodyParams dictionary as the POST body.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param bodyParams The dictionary used in the POST body.
 @param completion The completion block that will be fired once the request has completed.
 */
- (void)post:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary bodyParams:(NSDictionary *)bodyParams completion:(TSCRequestCompletionHandler)completion;

/**
 Performs a POST request on the base URL using the supplied paramater dictionary to build the URL, and bodyParams dictionary as the POST body.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param bodyParams The dictionary used in the POST body.
 @param contentType The type of `TSCRequestContentType` to be used when encoding the request body
 @param completion The completion block that will be fired once the request has completed.
 */
- (void)post:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary bodyParams:(NSDictionary *)bodyParams contentType:(TSCRequestContentType)contentType completion:(TSCRequestCompletionHandler)completion;

///---------------------------------------------------------------------------------------
/// @name PUT requests
///---------------------------------------------------------------------------------------

/**
 Performs a PUT request on the base URL using the supplied bodyParams dictionary as the PUT body.
 @param path The path to be appended to the base URL.
 @param bodyParams The dictionary used in the PUT body.
 @param completion The completion block that will be fired once the request has completed.
 */
- (void)put:(NSString *)path bodyParams:(NSDictionary *)bodyParams completion:(TSCRequestCompletionHandler)completion;

/**
 Performs a PUT request on the base URL using the supplied paramater dictionary to build the URL, and bodyParams dictionary as the PUT body.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param bodyParams The dictionary used in the PUT body.
 @param completion The completion block that will be fired once the request has completed.
 */
- (void)put:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary bodyParams:(NSDictionary *)bodyParams completion:(TSCRequestCompletionHandler)completion;

///---------------------------------------------------------------------------------------
/// @name DELETE requests
///---------------------------------------------------------------------------------------

/**
 Performs a DELETE request on the base URL using the supplied paramater dictionary to build the URL.
 @param path The path to be appended to the base URL.
 @param completion The completion block that will be fired once the request has completed.
 */
- (void)delete:(NSString *)path completion:(TSCRequestCompletionHandler)completion;

/**
 Performs a DELETE request on the base URL using the supplied paramater dictionary to build the URL.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param completion The completion block that will be fired once the request has completed.
 */
- (void)delete:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary completion:(TSCRequestCompletionHandler)completion;

///---------------------------------------------------------------------------------------
/// @name HEAD requests
///---------------------------------------------------------------------------------------

/**
 Performs a HEAD request on the base URL using the supplied paramater dictionary to build the URL.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param completion The completion block that will be fired once the request has completed.
 */
- (void)head:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary completion:(TSCRequestCompletionHandler)completion;

@end
