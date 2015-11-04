#import "TSCRequestResponse.h"

@implementation TSCRequestResponse

- (nullable instancetype)initWithResponse:(nullable NSURLResponse *)response data:(nullable NSData *)data
{
    self = [super init];
    
    if (self) {
        self.data = data;
        self.HTTPResponse = (NSHTTPURLResponse *)response;
    }
    
    return self;
}

- (NSInteger)status
{
    return [self.HTTPResponse statusCode];
}

- (nullable NSObject *)object
{
    NSError *parseError;
    id parseObject;
    
    if (self.data) {
        
        parseObject = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:&parseError];
        
        if (!parseObject) {
            parseObject = [NSPropertyListSerialization propertyListWithData:self.data options:NSPropertyListMutableContainersAndLeaves format:NULL error:&parseError];
        }
    }
    
#ifdef DEBUG
    if (!_object) {
        _object = parseObject;
    }
    return _object;
#else
    if (parseError) {
        return nil;
    } else {
        return parseObject;
    }
#endif
}

- (void)setData:(NSData * __nullable)data
{
    _data = data;
#ifdef DEBUG
    if ([[self object] isKindOfClass:[NSArray class]]) {
        _array = (NSArray *)[self object];
    } else if ([[self object] isKindOfClass:[NSDictionary class]]) {
        _dictionary = (NSDictionary *)[self object];
    }
    _string = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
#endif
}

- (nullable NSArray *)array
{
#ifdef DEBUG
    return _array;
#else
    return (NSArray * )[self object];
#endif
}

- (nullable NSDictionary *)dictionary
{
#ifdef DEBUG
    return _dictionary;
#else
    return (NSDictionary * )[self object];
#endif
}

- (nullable NSString *)string
{
#ifdef DEBUG
    return _string;
#else
	if (!self.data) {
		return nil;
	}
    return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
#endif
}

- (nullable NSDictionary *)responseHeaders
{
    return self.HTTPResponse.allHeaderFields;
}

@end
