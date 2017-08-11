//
//  CAUser.m
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CANetworkKeys.h"
#import "CAUserPrivate.h"
#import "CAObjectPrivate.h"
#import "NSDate+CAExtensions.h"

@interface CAUser ()
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *domain;
@property (nonatomic) NSString *domainHomePage;
@property (nonatomic) bool hasPrivateItems;
@property (nonatomic) bool isSubscribed;
@property (nonatomic) bool isAlpha;
@property (nonatomic) NSDate *subscriptionExpirationDate;
@property (nonatomic) NSInteger numberOfItems;
@property (nonatomic) NSInteger numberOfViews;
@end

@implementation CAUser

- (BOOL)updateWithDictionary:(NSDictionary *)dictionary {
    BOOL updated = [super updateWithDictionary:dictionary];
    if (updated) {
        self.email                      = dictionary[kEmail];
        self.domain                     = dictionary[kDomain];
        self.domainHomePage             = dictionary[kDomainHomePage];
        self.hasPrivateItems            = [dictionary[kPrivateItems] boolValue];
        self.isSubscribed               = [dictionary[kSubscribed] boolValue];
        self.isAlpha                    = [dictionary[kAlpha] boolValue];
        self.subscriptionExpirationDate = [NSDate dateFromISO8601String:dictionary[kSubscriptionExpirationDate]];
    }
    return updated;
}

- (void)updateStatisticsWithDictionary:(NSDictionary *)dictionary {
    self.numberOfItems = [dictionary[kItems] integerValue];
    self.numberOfViews = [dictionary[kViews] integerValue];
}

@end
