//
//  PCRequestController.h
//  Demo
//
//  Created by Phillip Caudell on 12/06/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSCRequest.h"

@interface TSCRequestController : NSObject

@property (nonatomic, strong) NSURL *sharedBaseURL;
@property (nonatomic, strong) NSMutableDictionary *sharedRequestHeaders;
@property (nonatomic, assign) TSCRequestContentType sharedContentType;
@property (nonatomic, strong) TSCRequestCredential *sharedRequestCredential;

- (id)initWithBaseURL:(NSURL *)baseURL;
- (id)initWithBaseAddress:(NSString *)baseAddress;

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

/**
 Performs a GET request on the base URL using the supplied object to build the URL.
 @param path The path to be appended to the base URL.
 @param URLParamObject Object used to build the URL.
 @param completion The completion block that will be fired once the request has completed.
 */
//- (void)get:(NSString *)path withURLParamObject:(NSObject *)URLParamObject completion:(PCRequestCompletionHandler)completion;

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

- (void)post:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary bodyParams:(NSDictionary *)bodyParams contentType:(TSCRequestContentType)contentType completion:(TSCRequestCompletionHandler)completion;

//- (void)post:(NSString *)path withURLParamObject:(NSDictionary *)URLParamObject bodyParams:(NSDictionary *)bodyParams completion:(PCRequestCompletionHandler)completion;

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

//- (void)put:(NSString *)path withURLParamObject:(NSDictionary *)URLParamObject bodyParams:(NSDictionary *)bodyParams completion:(PCRequestCompletionHandler)completion;

- (void)delete:(NSString *)path completion:(TSCRequestCompletionHandler)completion;

/**
 Performs a DELETE request on the base URL using the supplied paramater dictionary to build the URL.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param completion The completion block that will be fired once the request has completed.
 */
- (void)delete:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary completion:(TSCRequestCompletionHandler)completion;

/**
 Performs a HEAD request on the base URL using the supplied paramater dictionary to build the URL.
 @param path The path to be appended to the base URL.
 @param URLParamDictionary Dictionary used to build the URL.
 @param completion The completion block that will be fired once the request has completed.
 */
- (void)head:(NSString *)path withURLParamDictionary:(NSDictionary *)URLParamDictionary completion:(TSCRequestCompletionHandler)completion;

@end
