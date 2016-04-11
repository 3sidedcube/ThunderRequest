//
//  NSMutableURLRequest+TaskIdentifier.h
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/04/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (TaskIdentifier)

/**
 @abstract Can be used to get the task back for the request
 */
@property (nonatomic, assign) NSUInteger taskIdentifier;

@end
