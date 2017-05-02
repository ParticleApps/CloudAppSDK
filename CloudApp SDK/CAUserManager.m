//
//  CAUserManager.m
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CAUserPrivate.h"
#import "CAUserManager.h"
#import "CANetworkManager.h"

@interface CAUserManager () <NSURLSessionDelegate>
@property (nonatomic) NSURLCredential *credential;
@property (nonatomic) CAUser *currentUser;
@end

@implementation CAUserManager

#pragma mark - Initializers

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static CAUserManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Actions

- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure {
    self.credential = [CANetworkManager credentialForUsername:username password:password];
    [[CANetworkManager sharedInstance] getRequestWithURL:[NSURL URLWithString:@"http://my.cl.ly/account"] delegate:self completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        CAUser *user = nil;
        if (data != nil) {
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            if ([object isKindOfClass:[NSDictionary class]]) {
                user = [[CAUser alloc] initWithDictionary:(NSDictionary *)object];
                self.currentUser = user;
            }
        }
        
        if (user && success) {
            [[CANetworkManager sharedInstance] setUserCredential:self.credential];
            success(self.currentUser);
        }
        else if (failure) {
            self.credential = nil;
            failure(error);
        }
    }];
}

- (void)fetchStatisticsWithSuccess:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] getRequestWithURL:[NSURL URLWithString:@"http://my.cl.ly/account/stats"] completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        BOOL hasSuccess = false;
        if (data != nil) {
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [self.currentUser updateStatisticsWithDictionary:(NSDictionary *)object];
                hasSuccess = true;
            }
        }
        
        if (hasSuccess && success) {
            success(self.currentUser);
        }
        else if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([challenge previousFailureCount] == 0) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, self.credential);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    if ([challenge previousFailureCount] == 0) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, self.credential);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

@end
