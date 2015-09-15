#import <Foundation/Foundation.h>
#import "TSCRequestDefines.h"

/**
 A `TSCRequest` object represents a URL load request to be made be a `TSCRequestController`.
 
 Generally `TSCRequest` objects are created automatically by `TSCRequestController` although you may wish to manually construct and use a `TSCRequest` object.
 
 Requests are a subclass of `NSMutableURLRequest`
 
 */
@interface TSCRequest : NSMutableURLRequest

/**
 @abstract The Base URL for the request
 @discussion E.g. "http://api.mywebsite.com"
 */
@property (nonatomic, strong, nonnull) NSURL *baseURL;

/**
 @abstract The path to be appended to the `baseURL`.
 @discussion This should exclude the first "/" as this is appended automatically. E.g. "users/list.php"
 */
@property (nonatomic, strong, nonnull) NSString *path;

/**
 @abstract The HTTP method for the request (E.g. POST, GET...)
 */
@property (nonatomic, assign) TSCRequestHTTPMethod requestHTTPMethod;

/**
 @abstract The content type header for the request, such as "application/JSON"
 */
@property (nonatomic, assign) TSCRequestContentType contentType;

/**
 @abstract A dictionary to be used as the body of the request
 */
@property (nonatomic, strong, nullable) NSDictionary *bodyParameters;

/**
 @abstract A dictionary to be used as the headers for the request
 @dicussion This may be used to add keys such as "Authorization" or custom header fields.
 */
@property (nonatomic, strong, nullable) NSDictionary *requestHeaders;

/**
 @abstract The dictionary to be used to replace keys in the `path` component.
 @discussion For example a URL path could be constructed as "api/(:version)/users". The "(:version)" part of the path will be replaced by the value for the "version" key in this dictionary
 */
@property (nonatomic, strong, nullable) NSDictionary *URLParameterDictionary;

/**
 Configures the request with the set parameters and makes it ready for queuing 
 */
- (void)prepareForDispatch;

/**
 Returns a string compatible with NSURLRequest for the request type enum
 */
- (nullable NSString *)stringForHTTPMethod:(TSCRequestHTTPMethod)HTTPMethod;

@end

@interface NSString (MD5)

- (nonnull NSString *)MD5String;

@end