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
        dictionary = [self preprocessDictionary:dictionary];
        
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

- (NSDictionary *)preprocessDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *mutableDictioanry = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    for (NSString *key in dictionary.allKeys) {
        id value = mutableDictioanry[key];
        if ([value isKindOfClass:[NSNull class]]) {
            [mutableDictioanry setValue:@"" forKey:key];
        }
        else if ([value isKindOfClass:[NSString class]]) {
            if ([value isEqualToString:@"<null>"]) {
                [mutableDictioanry setValue:@"" forKey:key];
            }
        }
    }
    
    return mutableDictioanry;
}

@end
