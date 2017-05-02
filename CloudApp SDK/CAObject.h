//
//  CAObject.h
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAObject : NSObject
@property (nonatomic, readonly) NSInteger uniqueId;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSDate *updatedAt;

@end
