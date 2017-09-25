//
//  CAUploader.h
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/3/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import <CloudAppSDK/CloudAppSDK.h>

typedef NS_ENUM(NSInteger, CAUploaderStatus) {
    CAUploaderStatusHasNotStarted = 0,
    CAUploaderStatusRequestingNewItem = 1,
    CAUploaderStatusUploadingFile = 2,
    CAUploaderStatusFailed = 3,
    CAUploaderStatusComplete = 4
};

@protocol CAUploaderDelegate <NSObject>

- (void)uploaderStatusDidChange:(CAUploaderStatus)status;

@end

@interface CAUploader : CAObject

@property (nonatomic, readonly) CAUploaderStatus status;

@property (nonatomic) id<CAUploaderDelegate> delegate;

@property (nonatomic) NSString *path;

@property (nonatomic) NSString *name;

@property (nonatomic) BOOL isPrivate;

- (instancetype)initWithFilePath:(NSString *)path name:(NSString *)name;

- (void)upload:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;

@end
