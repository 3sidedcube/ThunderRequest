//
//  NSDictionary+URLEncoding.m
//  ThunderRequest
//
//  Created by Simon Mitchell on 23/02/2015.
//  Copyright (c) 2015 3 SIDED CUBE. All rights reserved.
//

#import "NSDictionary+URLEncoding.h"

@implementation NSDictionary (URLEncoding)

static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncode(id object) {
    NSString *string = toString(object);
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

+ (instancetype)dictionaryWithURLEncodedString:(NSString *)string
{
    NSString *queryString = [[NSURL URLWithString:string] query];
    
    NSMutableDictionary *result = [[[self alloc] init] mutableCopy];
    
    NSArray *parameters = [queryString componentsSeparatedByString:@"&"];
    
    for (NSString *parameter in parameters)
    {
        NSArray *parts = [parameter componentsSeparatedByString:@"="];
        NSString *key = [[parts objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([parts count] > 1)
        {
            id value = [[parts objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [result setObject:value forKey:key];
        }
    }
    
    return result;
}

- (NSString *)urlEncodedFormString
{
    if (self.allKeys.count == 0) {
        return nil;
    }
    
    NSMutableArray *parts = [NSMutableArray new];
    
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [parts addObject:[NSString stringWithFormat:@"%@=%@",urlEncode(key),urlEncode(obj)]];
    }];
    
    return [parts componentsJoinedByString:@"&"];
}

- (NSData *)urlEncodedFormData
{
    return [[self urlEncodedFormString] dataUsingEncoding:NSUTF8StringEncoding];
}

@end
