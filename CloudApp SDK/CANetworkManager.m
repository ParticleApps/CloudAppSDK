//
//  CANetworkManager.m
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CANetworkManager.h"

@interface CANetworkManager () <NSURLSessionDelegate>
@end

@implementation CANetworkManager

#pragma mark - Initializers

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static CANetworkManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Class Methods

+ (NSURLCredential *)credentialForUsername:(NSString *)username password:(NSString *)password {
    return [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistencePermanent];
}

#pragma mark - Actions

- (void)getRequestWithURL:(NSURL *)url completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    [self getRequestWithURL:url delegate:self completion:completion];
}

- (void)getRequestWithURL:(NSURL *)url delegate:(id<NSURLSessionDelegate>)delegate completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session                    = [NSURLSession sessionWithConfiguration:configuration delegate:delegate delegateQueue:nil];
    NSMutableURLRequest *request             = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"GET"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:completion];
    [task resume];
}

#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([challenge previousFailureCount] == 0) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, self.userCredential);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    if ([challenge previousFailureCount] == 0) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, self.userCredential);
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}


@end
