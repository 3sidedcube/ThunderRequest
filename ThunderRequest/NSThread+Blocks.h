//
//  NSThread+Blocks.h
//  ThunderRequest
//
//  Created by Simon Mitchell on 23/10/2015.
//  Copyright © 2015 threesidedcube. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Category on NSThread which allows performing blocks of code on them
 */
@interface NSThread (Blocks)

/**
 Performs a block of code on the current thread
 @param block The block of code to call
 */
- (void)performBlock:(void (^)())block;

/**
 Performs a block of code on the current thread
 @param block The block of code to call
 @param wait Weather the thread should wait until the block of code is run
 */
- (void)performBlock:(void (^)())block waitUntilDone:(BOOL)wait;

/**
 Performs a block of code on the current thread
 @param block The block of code to call
 @param delay A time interval to wait until the block of code is run
 */
- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;

@end
