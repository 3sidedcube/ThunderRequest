#import <Foundation/Foundation.h>

/**
 A more useful representation of a NSURLResponse object. This object contains useful properties to help access response data from a data request quickly
 */
@interface TSCRequestResponse : NSObject

/**
 @abstract A dictionary representation of the headers the server responded with
 */
@property (nonatomic, strong, nullable) NSDictionary *responseHeaders;

/**
 @abstract Raw NSData returned from the server
 */
@property (nonatomic, strong, nullable) NSData *data;

/**
 @abstract The NSHTTPURLResponse object returned from the request. Contains information such as HTTP response code
 */
@property (nonatomic, strong, nullable) NSHTTPURLResponse *HTTPResponse;

/**
 @abstract A HTTP response code
 */
@property (nonatomic, assign) NSInteger status;

/**
 @abstract An array representation of the response data
 */
@property (nonatomic, strong, nullable) NSArray *array;

/**
 @abstract An dictionary representation of the response data
 */
@property (nonatomic, strong, nullable) NSDictionary *dictionary;

/**
 @abstract An string representation of the response data
 */
@property (nonatomic, copy, nullable) NSString *string;

/**
 @abstract An object representation of the response data. Parsed from JSON.
 */
@property (nonatomic, strong, nullable) NSObject *object;

/**
 @abstract The redirect response
 @discussion If the request was redirected, this represents the NSHTTPURLResponse object for the original request
 */
@property (nonatomic, strong, nullable) NSHTTPURLResponse *redirectResponse;

/**
 Initialises a new response object using the response given by NSURLSession
 */
- (nullable instancetype)initWithResponse:(nullable NSURLResponse *)response data:(nullable NSData *)data;

@end
