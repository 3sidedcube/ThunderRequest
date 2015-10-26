//
//  NSThread+Blocks.m
//  ThunderRequest
//
//  Created by Simon Mitchell on 23/10/2015.
//  Copyright © 2015 threesidedcube. All rights reserved.
//

#import "NSThread+Blocks.h"

@implementation NSThread (Blocks)

+ (void)runBlock:(void (^)())block
{
    if (block) {
        block();
    }
}

- (void)performBlock:(void (^)())block
{
    if ([[NSThread currentThread] isEqual:self]) {
        
        if (block) {
            block();
        }
        
    } else {
        [self performBlock:block waitUntilDone:false];
    }
}

- (void)performBlock:(void (^)())block waitUntilDone:(BOOL)wait
{
    [NSThread performSelector:@selector(runBlock:) onThread:self withObject:[block copy] waitUntilDone:wait];
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(performBlock:) withObject:[block copy] afterDelay:delay];
}

@end
