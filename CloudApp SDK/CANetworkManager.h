//
//  CANetworkManager.h
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CANetworkManager : NSObject

@property (nonatomic) NSURLCredential *userCredential;

+ (instancetype)sharedInstance;

+ (NSURLCredential *)credentialForUsername:(NSString *)username password:(NSString *)password;

- (void)getRequestWithURL:(NSURL *)url completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

- (void)getRequestWithURL:(NSURL *)url delegate:(id<NSURLSessionDelegate>)delegate completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

@end
