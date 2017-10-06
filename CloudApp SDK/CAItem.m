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
@property (nonatomic) NSNumber *contentSize;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *slug;
@property (nonatomic) BOOL isPrivate;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) BOOL isSubscribed;
@property (nonatomic) NSURL *url;
@property (nonatomic) NSURL *contentURL;
@property (nonatomic) NSURL *downloadURL;
@property (nonatomic) CAItemType type;
@property (nonatomic) NSInteger views;
@property (nonatomic) NSURL *iconURL;
@property (nonatomic) NSURL *remoteURL;
@property (nonatomic) NSURL *redirectURL;
@property (nonatomic) NSString *source;
@property (nonatomic) NSDate *deteledAt;
@property (nonatomic) NSDate *expiresAt;
@property (nonatomic) NSInteger expiresAfter;
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
    
    return CAItemTypeUnknown;
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
    if (![mutableDictionary[kContentSize] isKindOfClass:[NSNumber class]]) {
        mutableDictionary[kContentSize] = @(0);
    }
    
    return mutableDictionary;
}

- (BOOL)updateWithDictionary:(NSDictionary *)dictionary {
    BOOL changed = [super updateWithDictionary:dictionary];
    if (changed) {
        self.name         = dictionary[kName];
        self.contentSize  = dictionary[kContentSize];
        self.isPrivate    = [dictionary[kPrivate] boolValue];
        self.isFavorite   = [dictionary[kFavorite] boolValue];
        self.isSubscribed = [dictionary[kSubscribed] boolValue];
        self.url          = [NSURL URLWithString:dictionary[kURL]];
        self.downloadURL  = [NSURL URLWithString:dictionary[kDownloadURL]];
        self.contentURL   = [NSURL URLWithString:dictionary[kContentURL]];
        self.type         = [CAItem typeForAPIValue:dictionary[kItemType]];
        self.views        = [dictionary[kViewCounter] integerValue];
        self.iconURL      = [NSURL URLWithString:dictionary[kIcon]];
        self.remoteURL    = [NSURL URLWithString:dictionary[kRemoteURL]];
        self.redirectURL  = [NSURL URLWithString:dictionary[kRedirectURL]];
        self.source       = dictionary[kSource];
        self.deteledAt    = [NSDate dateFromISO8601String:dictionary[kDeletedAt]];
        self.expiresAt    = [NSDate dateFromISO8601String:dictionary[kExpiresAt]];
        self.expiresAfter = [dictionary[kExpiresAfter] integerValue];
        self.slug         = self.url.lastPathComponent;
    }
    return changed;
}

- (void)updateExpirationStatusWithDictionary:(NSDictionary *)dictionary {
    self.expiresAt    = [NSDate dateFromISO8601String:dictionary[kExpiresAt]];
    self.expiresAfter = [dictionary[kExpiresAfter] integerValue];
}

- (void)updateFavoriteStatusWithDictionary:(NSDictionary *)dictionary {
    self.isFavorite = [dictionary[kFavorite] boolValue];
}

@end
