//
//  NSDictionary+URLEncoding.h
//  ThunderRequest
//
//  Created by Simon Mitchell on 23/02/2015.
//  Copyright (c) 2015 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (URLEncoding)

- (NSData *)urlEncodedFormData;

- (NSString *)urlEncodedFormString;

+ (instancetype)dictionaryWithURLEncodedString:(NSString *)string;

@end
