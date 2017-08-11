//
//  CAUserManager.m
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CANetworkKeys.h"
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

#pragma mark - Handlers

- (void (^)(NSData *data, NSURLResponse *response, NSError *error))completionBlockForCurrentUserWithSuccess:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure {
    return ^(NSData *data, NSURLResponse *response, NSError *error) {
        BOOL hasSuccess = false;
        if (data != nil) {
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [self.currentUser updateWithDictionary:(NSDictionary *)object];
                hasSuccess = true;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hasSuccess && success) {
                success(self.currentUser);
            }
            else if (failure) {
                failure(error);
            }
        });
    };
}

- (void (^)(NSData *data, NSURLResponse *response, NSError *error))completionBlockForNewUserWithSuccess:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure {
    return ^(NSData *data, NSURLResponse *response, NSError *error) {
        CAUser *user = nil;
        if (data != nil) {
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            if ([object isKindOfClass:[NSDictionary class]]) {
                user = [[CAUser alloc] initWithDictionary:(NSDictionary *)object];
                self.currentUser = user;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (user && success) {
                [[CANetworkManager sharedInstance] setUserCredential:self.credential];
                success(self.currentUser);
            }
            else if (failure) {
                self.credential = nil;
                failure(error);
            }
        });
    };
}

#pragma mark - Fetch

- (void)fetchStatisticsWithSuccess:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] getRequestWithURL:[CANetworkManager secureUrlWithExtension:statisticsExtension] completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        BOOL hasSuccess = false;
        if (data != nil) {
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [self.currentUser updateStatisticsWithDictionary:(NSDictionary *)object];
                hasSuccess = true;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hasSuccess && success) {
                success(self.currentUser);
            }
            else if (failure) {
                failure(error);
            }
        });
    }];
}

#pragma mark - Actions

- (void)logout {
    self.currentUser = nil;
    [[CANetworkManager sharedInstance] setUserCredential:nil];
    
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

- (void)registerWithEmail:(NSString *)email password:(NSString *)password acceptsToS:(BOOL)tos success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure {
    self.credential = [CANetworkManager credentialForEmail:email password:password];
    [[CANetworkManager sharedInstance] postRequestWithURL:[CANetworkManager secureUrlWithExtension:registerExtension]
                                                     body:@{kUser: @{kEmail : email, kUserPassword:password, kAcceptTOS:@(tos)}}
                                                 delegate:self
                                               completion:[self completionBlockForNewUserWithSuccess:success failure:failure]];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure {
    self.credential = [CANetworkManager credentialForEmail:email password:password];
    [[CANetworkManager sharedInstance] getRequestWithURL:[CANetworkManager secureUrlWithExtension:accountExtension]
                                                delegate:self
                                              completion:[self completionBlockForNewUserWithSuccess:success failure:failure]];
}

- (void)validateExistingCredentials:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] getRequestWithURL:[CANetworkManager secureUrlWithExtension:accountExtension]
                                              completion:[self completionBlockForNewUserWithSuccess:success failure:failure]];
}

- (void)requestPasswordReset:(NSString *)email success:(void (^)())success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] postRequestWithURL:[CANetworkManager secureUrlWithExtension:resetPasswordExtension]
                                                     body:@{kUser:@{kEmail:email}}
                                               completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       if (error && failure) {
                                                           failure(error);
                                                       }
                                                       else if (!error && success) {
                                                           success();
                                                       }
                                                   });
                                               }];
}

- (void)setHasPrivateItems:(BOOL)privateItems success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] putRequestWithURL:[CANetworkManager secureUrlWithExtension:accountExtension]
                                                    body:@{kUser:@{kPrivateItems:@(privateItems)}}
                                              completion:[self completionBlockForCurrentUserWithSuccess:success failure:failure]];
}

- (void)setCustomDomain:(NSString *)domain homepage:(NSString *)homepage success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] putRequestWithURL:[CANetworkManager secureUrlWithExtension:accountExtension]
                                                    body:@{kUser: @{kDomain:domain, kDomainHomePage:homepage}}
                                              completion:[self completionBlockForCurrentUserWithSuccess:success failure:failure]];
}

- (void)setPassword:(NSString *)newPassword currentPassword:(NSString *)oldPassword success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] putRequestWithURL:[CANetworkManager secureUrlWithExtension:accountExtension]
                                                    body:@{kUser:@{kUserPassword:newPassword, kCurrnetPassword:oldPassword}}
                                              completion:[self completionBlockForCurrentUserWithSuccess:success failure:failure]];
}

- (void)setEmail:(NSString *)email currentPassword:(NSString *)oldPassword success:(void (^)(CAUser *user))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] putRequestWithURL:[CANetworkManager secureUrlWithExtension:accountExtension]
                                                    body:@{kUser:@{kEmail:email, kCurrnetPassword:oldPassword}}
                                              completion:[self completionBlockForCurrentUserWithSuccess:success failure:failure]];
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
