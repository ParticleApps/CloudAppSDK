//
//  NSDate+CAExtensions.h
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CAExtensions)

+ (NSDate *)dateFromISO8601String:(NSString *)iso8601String;

- (NSString *)ISO8601String;

@end
