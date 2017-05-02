//
//  CAUserManager.h
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CAUser.h"

@interface CAUserManager : NSObject

@property (nonatomic, readonly) CAUser *currentUser;

+ (instancetype)sharedInstance;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

- (void)fetchStatisticsWithSuccess:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

@end
