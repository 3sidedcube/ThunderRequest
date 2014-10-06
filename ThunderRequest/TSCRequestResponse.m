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
    return [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
}

- (NSArray *)array
{
    return (NSArray * )[self object];
}

- (NSDictionary *)dictionary
{
    return (NSDictionary * )[self object];
}

- (NSString *)string
{
    return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)responseHeaders
{
    return self.HTTPResponse.allHeaderFields;
}

@end
