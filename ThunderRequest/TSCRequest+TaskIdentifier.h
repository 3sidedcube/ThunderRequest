//
//  TSCRequest+TaskIdentifier.h
//  ThunderRequest
//
//  Created by Simon Mitchell on 27/01/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

#import "TSCRequest.h"

@interface TSCRequest (TaskIdentifier)

/**
 @abstract Can be used to get the task back for the request
 */
@property (nonatomic, assign) NSUInteger taskIdentifier;

@end
