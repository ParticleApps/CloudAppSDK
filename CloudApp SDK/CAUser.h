//
//  CAUser.h
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CAObject.h"

@interface CAUser : CAObject

@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *domain;
@property (nonatomic, readonly) NSString *domainHomePage;
@property (nonatomic, readonly) bool hasPrivateItems;
@property (nonatomic, readonly) bool isSubscribed;
@property (nonatomic, readonly) bool isAlpha;
@property (nonatomic, readonly) NSDate *subscriptionExpirationDate;
@property (nonatomic, readonly) NSInteger numberOfItems;
@property (nonatomic, readonly) NSInteger numberOfViews;

@end
