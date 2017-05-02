//
//  CAObject.m
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CANetworkKeys.h"
#import "CAObjectPrivate.h"
#import "NSDate+CAExtensions.h"

@interface CAObject ()
@property (nonatomic) NSInteger uniqueId;
@property (nonatomic) NSDate *createdAt;
@property (nonatomic) NSDate *updatedAt;
@end

@implementation CAObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.uniqueId  = [dictionary[kUniqueId] integerValue];
        self.createdAt = [NSDate dateFromISO8601String:dictionary[kCreatedAt]];
        
        [self updateWithDictionary:dictionary];
    }
    return self;
}

- (BOOL)updateWithDictionary:(NSDictionary *)dictionary {
    //TODO: Check date
    BOOL updated = true;
    
    if (updated) {
        self.updatedAt = [NSDate dateFromISO8601String:dictionary[kUpdatedAt]];
        
        return true;
    }
    
    return updated;
}

@end
