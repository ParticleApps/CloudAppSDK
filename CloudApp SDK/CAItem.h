//
//  CAItem.h
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/2/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CAObject.h"

typedef NS_ENUM(NSInteger, CAItemType) {
    CAItemTypeAll      = 0,
    CAItemTypeImage    = 1,
    CAItemTypeText     = 2,
    CAItemTypeBookmark = 3,
    CAItemTypeVideo    = 4,
    CAItemTypeArchive  = 5,
    CAItemTypeAudio    = 6,
    CAItemTypeUnknown  = 7
};

@interface CAItem : CAObject
@property (nonatomic, readonly) NSNumber *contentSize;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *slug;
@property (nonatomic, readonly) NSURL *href;
@property (nonatomic, readonly) BOOL isPrivate;
@property (nonatomic, readonly) BOOL isFavorite;
@property (nonatomic, readonly) BOOL isSubscribed;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSURL *contentURL;
@property (nonatomic, readonly) NSURL *downloadURL;
@property (nonatomic, readonly) CAItemType type;
@property (nonatomic, readonly) NSInteger views;
@property (nonatomic, readonly) NSURL *iconURL;
@property (nonatomic, readonly) NSURL *remoteURL;
@property (nonatomic, readonly) NSURL *redirectURL;
@property (nonatomic, readonly) NSString *source;
@property (nonatomic, readonly) NSDate *deteledAt;
@property (nonatomic, readonly) NSDate *expiresAt;
@property (nonatomic, readonly) NSInteger expiresAfter;
@end
