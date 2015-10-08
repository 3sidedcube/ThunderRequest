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
