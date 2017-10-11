//
//  CAObject.m
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CANetworkKeys.h"
#import "CAObjectPrivate.h"
#import "NSDate+CACatagories.h"

@interface CAObject ()
@property (nonatomic) NSInteger uniqueId;
@property (nonatomic) NSDate *createdAt;
@property (nonatomic) NSDate *updatedAt;
@end

@implementation CAObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        dictionary = [self preprocessedDictionary:dictionary];
        
        self.uniqueId  = [dictionary[kUniqueId] integerValue];
        self.createdAt = [NSDate dateFromISO8601String:dictionary[kCreatedAt]];
        
        [self updateWithDictionary:dictionary];
    }
    return self;
}

- (BOOL)updateWithDictionary:(NSDictionary *)dictionary {
    dictionary = [self preprocessedDictionary:dictionary];
    NSDate *updatedAt = [NSDate dateFromISO8601String:dictionary[kUpdatedAt]];
    if ([self.updatedAt compare:updatedAt] == NSOrderedDescending || !self.updatedAt) {
        self.updatedAt = updatedAt;
        
        return true;
    }
    return false;
}

- (NSDictionary *)preprocessedDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *mutableDictioanry = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    //HACK: Cleaning the dictionary here is probably not great practice
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
