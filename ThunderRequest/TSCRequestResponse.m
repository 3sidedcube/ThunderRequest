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
    
    if (self.data) {
        
        id parseObject = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:&parseError];
        
        if (parseError) {
            return nil;
        } else {
            return parseObject;
        }
        
    } else {
        return nil;
    }
}

- (nullable NSArray *)array
{
    return (NSArray * )[self object];
}

- (nullable NSDictionary *)dictionary
{
    return (NSDictionary * )[self object];
}

- (nullable NSString *)string
{
    return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
}

- (nullable NSDictionary *)responseHeaders
{
    return self.HTTPResponse.allHeaderFields;
}

@end
