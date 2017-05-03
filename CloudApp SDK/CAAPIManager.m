//
//  CAAPIManager.m
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/2/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CAAPIManager.h"
#import "CANetworkKeys.h"
#import "CANetworkManager.h"
#import "CAObjectPrivate.h"
#import "CAItemPrivate.h"

@implementation CAAPIManager

#pragma mark - Initializers

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static CAAPIManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.defaultItemsPerPage = 30;
    }
    return self;
}

#pragma mark - Handlers

- (void (^)(NSData *data, NSURLResponse *response, NSError *error))completionBlockForItemsWithSuccess:(void (^)(NSArray<CAItem *> *items))success failure:(void (^)(NSError *error))failure {
    return ^(NSData *data, NSURLResponse *response, NSError *error) {
        NSMutableArray <CAItem *> *items = nil;
        if (data != nil) {
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            if ([object isKindOfClass:[NSArray class]]) {
                items = [NSMutableArray array];
                for (NSDictionary *dictionary in (NSArray *)object) {
                    CAItem *item = [[CAItem alloc] initWithDictionary:dictionary];
                    [items addObject:item];
                }
            }
        }
        
        if (items && success) {
            success(items);
        }
        else if (!items && failure) {
            failure(error);
        }
    };
}

#pragma mark - Getters

- (void)fetchItemsAtPage:(NSInteger)page success:(void (^)(NSArray<CAItem *> *items))success failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters = @{kPage:@(page),kItemsPerPage:@(self.defaultItemsPerPage)};
    [[CANetworkManager sharedInstance] getRequestWithURL:[CANetworkManager urlWithExtension:itemsExtension parameters:parameters]
                                              completion:[self completionBlockForItemsWithSuccess:success failure:failure]];
}

- (void)fetchItemsAtPage:(NSInteger)page
    numberOfItemsPerPage:(NSInteger)numberOfItems
                    type:(CAItemType)type
                 success:(void (^)())success
                 failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters = @{kPage:@(page),kItemsPerPage:@(numberOfItems),kType:[CAItem apiValueForItemType:type]};
    [[CANetworkManager sharedInstance] getRequestWithURL:[CANetworkManager urlWithExtension:itemsExtension parameters:parameters]
                                              completion:[self completionBlockForItemsWithSuccess:success failure:failure]];
}

- (void)fetchArchivedItemsAtPage:(NSInteger)page success:(void (^)())success failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters = @{kPage:@(page),kItemsPerPage:@(self.defaultItemsPerPage), kDeleted:@(true)};
    [[CANetworkManager sharedInstance] getRequestWithURL:[CANetworkManager urlWithExtension:itemsExtension parameters:parameters]
                                              completion:[self completionBlockForItemsWithSuccess:success failure:failure]];
}

- (void)fetchArchievedItemsAtPage:(NSInteger)page
             numberOfItemsPerPage:(NSInteger)numberOfItems
                             type:(CAItemType)type
                          success:(void (^)())success
                          failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters = @{kPage:@(page),kItemsPerPage:@(numberOfItems), kType:[CAItem apiValueForItemType:type], kDeleted:@(true)};
    [[CANetworkManager sharedInstance] getRequestWithURL:[CANetworkManager urlWithExtension:itemsExtension parameters:parameters]
                                              completion:[self completionBlockForItemsWithSuccess:success failure:failure]];
}

@end
