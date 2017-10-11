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

//Fetch
- (void)fetchStatisticsWithSuccess:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

//Actions
- (void)logout;

- (void)registerWithEmail:(NSString *)email password:(NSString *)password acceptsToS:(BOOL)tos success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

- (void)validateExistingCredentials:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

- (void)requestPasswordReset:(NSString *)email success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

- (void)setHasPrivateItems:(BOOL)privateItems success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

- (void)setCustomDomain:(NSString *)domain homepage:(NSString *)homepage success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

- (void)setPassword:(NSString *)newPassword currentPassword:(NSString *)oldPassword success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

- (void)setEmail:(NSString *)email currentPassword:(NSString *)oldPassword success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure;

@end
