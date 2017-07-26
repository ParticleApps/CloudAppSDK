//
//  CAItem.m
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/2/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CAItem.h"
#import "CANetworkKeys.h"
#import "CAItemPrivate.h"
#import "CAObjectPrivate.h"
#import "NSDate+CAExtensions.h"

@interface CAItem ()
@property (nonatomic) NSString *name;
@property (nonatomic) BOOL isPrivate;
@property (nonatomic) BOOL isSubscribed;
@property (nonatomic) NSURL *url;
@property (nonatomic) NSURL *contentURL;
@property (nonatomic) CAItemType type;
@property (nonatomic) NSInteger views;
@property (nonatomic) NSURL *iconURL;
@property (nonatomic) NSURL *remoteURL;
@property (nonatomic) NSURL *redirectURL;
@property (nonatomic) NSString *source;
@property (nonatomic) NSDate *deteledAt;
@end

@implementation CAItem

+ (CAItemType)typeForAPIValue:(NSString *)value {
    if ([value isEqualToString:kImage]) {
        return CAItemTypeImage;
    }
    if ([value isEqualToString:kText]) {
        return CAItemTypeText;
    }
    else if ([value isEqualToString:kVideo]) {
        return CAItemTypeVideo;
    }
    else if ([value isEqualToString:kArchive]) {
        return CAItemTypeArchive;
    }
    else if ([value isEqualToString:kBookmark]) {
        return CAItemTypeBookmark;
    }
    else if ([value isEqualToString:kAudio]) {
        return CAItemTypeAudio;
    }
    
    return CAItemTypeUnkown;
}

+ (NSString *)apiValueForItemType:(CAItemType)type {
    switch (type) {
        case CAItemTypeBookmark:
            return kBookmark;
        case CAItemTypeArchive:
            return kArchive;
        case CAItemTypeVideo:
            return kVideo;
        case CAItemTypeText:
            return kText;
        case CAItemTypeImage:
            return kImage;
        case CAItemTypeAudio:
            return kAudio;
        default:
            return kUnkown;
    }
}

- (NSDictionary *)preprocessedDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *mutableDictionary = [[super preprocessedDictionary:dictionary] mutableCopy];
    NSURL *url = [NSURL URLWithString:dictionary[kHref]];
    NSInteger uniqueId = [url.lastPathComponent integerValue];
    
    mutableDictionary[kUniqueId] = @(uniqueId);
    
    if (![mutableDictionary.allKeys containsObject:kURL] && [mutableDictionary.allKeys containsObject:kShareURL]) {
        mutableDictionary[kURL] = mutableDictionary[kShareURL];
    }
    
    return mutableDictionary;
}

- (BOOL)updateWithDictionary:(NSDictionary *)dictionary {
    BOOL changed = [super updateWithDictionary:dictionary];
    if (changed) {
        self.name         = dictionary[kName];
        self.isPrivate    = [dictionary[kPrivate] boolValue];
        self.isSubscribed = [dictionary[kSubscribed] boolValue];
        self.url          = [NSURL URLWithString:dictionary[kURL]];
        self.contentURL   = [NSURL URLWithString:dictionary[kContentURL]];
        self.type         = [CAItem typeForAPIValue:dictionary[kItemType]];
        self.views        = [dictionary[kViewCounter] integerValue];
        self.iconURL      = [NSURL URLWithString:dictionary[kIcon]];
        self.remoteURL    = [NSURL URLWithString:dictionary[kRemoteURL]];
        self.redirectURL  = [NSURL URLWithString:dictionary[kRedirectURL]];
        self.source       = dictionary[kSource];
        self.deteledAt    = [NSDate dateFromISO8601String:dictionary[kDeletedAt]];
    }
    return changed;
}

@end
