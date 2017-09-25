//
//  CAUploader.m
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/3/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CAUploader.h"
#import "CANetworkKeys.h"
#import "CANetworkManager.h"

@interface CAUploader ()
@property (nonatomic) CAUploaderStatus status;
@property (nonatomic) NSDictionary *responseForNewItem;
@end

@implementation CAUploader

#pragma mark - Initializers

- (instancetype)initWithFilePath:(NSString *)path name:(NSString *)name {
    self = [self init];
    if (self) {
        self.name = name;
        self.path = path;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.status = CAUploaderStatusHasNotStarted;
        self.isPrivate = false;
    }
    return self;
}

#pragma mark - Actions

- (void)upload:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure {
    [self requestNewItem:success failure:failure];
}

- (void)requestNewItem:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure {
    self.status = CAUploaderStatusRequestingNewItem;
    [[CANetworkManager sharedInstance] postRequestWithURL:[self requestURL] body:@{kName : self.name} completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        BOOL localSuccess = false;
        if (data != nil) {
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            if ([object isKindOfClass:[NSDictionary class]]) {
                localSuccess = true;
                self.responseForNewItem = (NSDictionary *)object;
                [self uploadNewItem:success failure:failure];
            }
        }
        if (!localSuccess) {
            self.status = CAUploaderStatusFailed;
        }
        if (!localSuccess && failure) {
            failure(error);
        }
    }];
}

- (void)uploadNewItem:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure {
    self.status = CAUploaderStatusUploadingFile;
    [[CANetworkManager sharedInstance] multiPartPostRequestWithURL:[NSURL URLWithString:self.responseForNewItem[kURL]]
                                                               body:[self uploadBody]
                                                               path:self.path
                                                         completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        BOOL localSuccess = false;
        if (data != nil) {
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            if ([object isKindOfClass:[NSDictionary class]]) {
                self.status = CAUploaderStatusComplete;
                localSuccess = true;
                success(object);
            }
        }
        if (!localSuccess) {
            self.status = CAUploaderStatusFailed;
        }
        if (!localSuccess && failure) {
            failure(error);
        }
    }];
}

#pragma mark - Setters

- (void)setStatus:(CAUploaderStatus)status {
    _status = status;
    
    if (self.delegate) {
        [self.delegate uploaderStatusDidChange:status];
    }
}

#pragma mark - Helpers

- (NSURL *)requestURL {
    //HACK: The current URL seems to broken, hard linked to the deprecated URL as a patch
    //return [CANetworkManager secureUrlWithExtension:newItemExtension];
    if (self.isPrivate) {
        return [NSURL URLWithString:@"http://my.cl.ly/items/new?item[private]=false"];
    }
    return [NSURL URLWithString:@"http://my.cl.ly/items/new"];
}

- (NSDictionary *)uploadBody {
    if ([self.responseForNewItem.allKeys containsObject:kS3]) {
        return self.responseForNewItem[kS3];
    }
    return self.responseForNewItem[kParams];
}

@end
