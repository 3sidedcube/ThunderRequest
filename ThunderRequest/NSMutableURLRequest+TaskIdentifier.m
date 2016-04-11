//
//  NSMutableURLRequest+TaskIdentifier.m
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/04/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

#import "NSMutableURLRequest+TaskIdentifier.h"
#import <objc/runtime.h>

@implementation NSMutableURLRequest (TaskIdentifier)

static char taskIdentifierKey;

- (NSUInteger)taskIdentifier
{
    return [objc_getAssociatedObject(self, &taskIdentifierKey) integerValue];
}

- (void)setTaskIdentifier:(NSUInteger)taskIdentifier
{
    objc_setAssociatedObject(self, &taskIdentifierKey, @(taskIdentifier), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
