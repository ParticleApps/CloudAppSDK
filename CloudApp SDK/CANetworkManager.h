//
//  CANetworkManager.h
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const accountExtension;
extern NSString *const statisticsExtension;
extern NSString *const registerExtension;
extern NSString *const resetPasswordExtension;
extern NSString *const itemsExtension;
extern NSString *const newItemExtension;

@interface CANetworkManager : NSObject

@property (nonatomic) NSURLCredential *userCredential;

+ (instancetype)sharedInstance;

+ (NSURL *)urlWithExtension:(NSString *)extension;

+ (NSURL *)urlWithExtension:(NSString *)extension parameters:(NSDictionary *)parameters;

+ (NSURLCredential *)credentialForEmail:(NSString *)email password:(NSString *)password;

- (void)getRequestWithURL:(NSURL *)url completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

- (void)getRequestWithURL:(NSURL *)url delegate:(id<NSURLSessionDelegate>)delegate completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

- (void)putRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

- (void)putRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody delegate:(id<NSURLSessionDelegate>)delegate completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

- (void)postRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

- (void)postRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody delegate:(id<NSURLSessionDelegate>)delegate completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

- (void)deleteRequestWithURL:(NSURL *)url completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

- (void)deleteRequestWithURL:(NSURL *)url delegate:(id<NSURLSessionDelegate>)delegate completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

- (void)multiPartPostRequestWithURL:(NSURL *)url body:(NSDictionary *)jsonBody path:(NSString *)path completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

@end
