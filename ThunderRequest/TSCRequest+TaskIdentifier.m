//
//  TSCRequest+TaskIdentifier.m
//  ThunderRequest
//
//  Created by Simon Mitchell on 27/01/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

#import "TSCRequest+TaskIdentifier.h"
#import <objc/runtime.h>

@implementation TSCRequest (TaskIdentifier)

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
