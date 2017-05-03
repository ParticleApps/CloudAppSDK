//
//  CANetworkManager.m
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CANetworkManager.h"

NSString *const accountExtension       = @"account";
NSString *const statisticsExtension    = @"stats";
NSString *const registerExtension      = @"register";
NSString *const resetPasswordExtension = @"reset";
NSString *const itemsExtension         = @"items";

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

+ (NSURLCredential *)credentialForEmail:(NSString *)email password:(NSString *)password {
    return [NSURLCredential credentialWithUser:email password:password persistence:NSURLCredentialPersistencePermanent];
}

+ (NSURL *)urlWithExtension:(NSString *)extension {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://my.cl.ly/%@", extension]];
}

+ (NSURL *)urlWithExtension:(NSString *)extension parameters:(NSDictionary *)parameters {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[CANetworkManager urlWithExtension:extension] resolvingAgainstBaseURL:NO];
    NSMutableArray *queryItems = [NSMutableArray arrayWithArray:components.queryItems];
    for (id parameter in parameters.allKeys) {
        id key = parameter;
        id value = parameters[key];
        
        if (![key isKindOfClass:[NSString class]]) {
            key = [key stringValue];
        }
        if (![value isKindOfClass:[NSString class]]) {
            value = [value stringValue];
        }
        
        NSURLQueryItem *queryItem = [[NSURLQueryItem alloc] initWithName:key value:value];
        [queryItems addObject:queryItem];
    }
    [components setQueryItems:queryItems];
    
    return components.URL;
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

- (void)putRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    [self putRequestWithURL:url body:jsonBody delegate:self completion:completion];
}

- (void)putRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody delegate:(id<NSURLSessionDelegate>)delegate completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSError *serializationError              = nil;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session                    = [NSURLSession sessionWithConfiguration:configuration delegate:delegate delegateQueue:nil];
    NSMutableURLRequest *request             = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSData *body                             = [NSJSONSerialization dataWithJSONObject:jsonBody options:(NSJSONWritingOptions)0 error:&serializationError];
    
    [request setHTTPBody:body];
    [request setHTTPMethod:@"PUT"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:completion];
    [task resume];
}

- (void)postRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    [self postRequestWithURL:url body:jsonBody delegate:self completion:completion];
}

- (void)postRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody delegate:(id<NSURLSessionDelegate>)delegate completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSError *serializationError              = nil;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session                    = [NSURLSession sessionWithConfiguration:configuration delegate:delegate delegateQueue:nil];
    NSMutableURLRequest *request             = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSData *body                             = [NSJSONSerialization dataWithJSONObject:jsonBody options:(NSJSONWritingOptions)0 error:&serializationError];
    
    [request setHTTPBody:body];
    [request setHTTPMethod:@"POST"];
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
