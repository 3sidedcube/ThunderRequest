//
//  PCRequestResponse.m
//  Demo
//
//  Created by Phillip Caudell on 12/06/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import "TSCRequestResponse.h"

@implementation TSCRequestResponse

- (id)initWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data
{
    self = [super init];
    
    if (self) {
        
        self.data = data;
        self.HTTPResponse = response;
    }
    
    return self;
}

- (TSCResponseStatus)status
{
    return [self.HTTPResponse statusCode];
}

- (NSObject *)object
{
    
#ifdef DEBUG
    if (!_object && self.data) {
        _object = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
    }
    return _object;
#endif
    return [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
}

- (void)setData:(NSData *)data
{
    _data = data;
    
#ifdef DEBUG
    if ([[self object] isKindOfClass:[NSArray class]]) {
        self.array = (NSArray *)[self object];
    } else if ([[self object] isKindOfClass:[NSDictionary class]]) {
        self.dictionary = (NSDictionary *)[self object];
    }
    
    self.string = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
#endif
}

- (NSDictionary *)dictionary
{
#ifdef DEBUG
    return _dictionary;
#endif
    return (NSDictionary *)[self object];
}

- (NSArray *)array
{
#ifdef DEBUG
    return _array;
#endif
    return (NSArray *)[self object];
}

- (NSString *)string
{
    
#ifdef DEBUG
    return _string;
#endif
    return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)responseHeaders
{
    return self.HTTPResponse.allHeaderFields;
}

@end
