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
#import "CAUploader.h"

NSString *const bookmarkNameKey = @"name";
NSString *const bookmarkURLKey  = @"redirect_url";

@implementation CAAPIManager

//TODO: Implement Share Functions
//TODO: Implement Favorite Functions
//TODO: Implement CloudApp Stream API
//TODO: Implement List Items by Source
//TODO: Implement Expiration Functions
//TODO: Implement Upload File With Specific Privacy

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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (items && success) {
                success(items);
            }
            else if (!items && failure) {
                failure(error);
            }
        });
    };
}

- (void (^)(NSData *data, NSURLResponse *response, NSError *error))completionBlockForItemWithSuccess:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure {
    return ^(NSData *data, NSURLResponse *response, NSError *error) {
        CAItem *item = nil;
        if (data != nil) {
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            if ([object isKindOfClass:[NSDictionary class]]) {
                item = [[CAItem alloc] initWithDictionary:(NSDictionary *)object];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (item && success) {
                success(item);
            }
            else if (!item && failure) {
                failure(error);
            }
        });
    };
}

- (void (^)(NSData *data, NSURLResponse *response, NSError *error))completionBlockForItemUpdate:(CAItem *)item success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure {
    return ^(NSData *data, NSURLResponse *response, NSError *error) {
        BOOL successful = false;
        if (data != nil) {
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [item updateWithDictionary:(NSDictionary *)object];
                successful = true;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (successful && success) {
                success(item);
            }
            else if (!successful && failure) {
                failure(error);
            }
        });
    };
}

#pragma mark - Fetch

- (void)fetchItemsAtPage:(NSInteger)page success:(void (^)(NSArray<CAItem *> *items))success failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters = @{kPage:@(page),kItemsPerPage:@(self.defaultItemsPerPage)};
    [[CANetworkManager sharedInstance] getRequestWithURL:[CANetworkManager secureUrlWithExtension:itemsExtension parameters:parameters]
                                              completion:[self completionBlockForItemsWithSuccess:success failure:failure]];
}

- (void)fetchItemsAtPage:(NSInteger)page
    numberOfItemsPerPage:(NSInteger)numberOfItems
                    type:(CAItemType)type
                 success:(void (^)())success
                 failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters = @{kPage:@(page),kItemsPerPage:@(numberOfItems),kType:[CAItem apiValueForItemType:type]};
    [[CANetworkManager sharedInstance] getRequestWithURL:[CANetworkManager secureUrlWithExtension:itemsExtension parameters:parameters]
                                              completion:[self completionBlockForItemsWithSuccess:success failure:failure]];
}

- (void)fetchArchivedItemsAtPage:(NSInteger)page success:(void (^)())success failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters = @{kPage:@(page),kItemsPerPage:@(self.defaultItemsPerPage), kDeleted:@(true)};
    [[CANetworkManager sharedInstance] getRequestWithURL:[CANetworkManager secureUrlWithExtension:itemsExtension parameters:parameters]
                                              completion:[self completionBlockForItemsWithSuccess:success failure:failure]];
}

- (void)fetchArchievedItemsAtPage:(NSInteger)page
             numberOfItemsPerPage:(NSInteger)numberOfItems
                             type:(CAItemType)type
                          success:(void (^)())success
                          failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters = @{kPage:@(page),kItemsPerPage:@(numberOfItems), kType:[CAItem apiValueForItemType:type], kDeleted:@(true)};
    [[CANetworkManager sharedInstance] getRequestWithURL:[CANetworkManager secureUrlWithExtension:itemsExtension parameters:parameters]
                                              completion:[self completionBlockForItemsWithSuccess:success failure:failure]];
}

- (void)fetchHomePageForDomain:(NSString *)domain success:(void (^)(NSString *homepage))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] getRequestWithURL:[NSURL URLWithString:[@"http://api.cld.me/domains/" stringByAppendingString:domain]]
                                              completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                  NSString *homePage = nil;
                                                  if (data != nil) {
                                                      id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:NULL];
                                                      if ([object isKindOfClass:[NSDictionary class]]) {
                                                          homePage = [(NSDictionary *)object objectForKey:kHomePage];
                                                      }
                                                  }
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      if (homePage && success) {
                                                          success(homePage);
                                                      }
                                                      else if (!homePage && failure) {
                                                          failure(error);
                                                      }
                                                  });
                                              }];
}

#pragma mark - Actions

- (void)createNewItem:(NSString *)name path:(NSString *)path success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure {
    CAUploader *uploader = [[CAUploader alloc] initWithFilePath:path name:name];
    [uploader upload:^(NSDictionary *response) {
        if (success) {
            CAItem *item = [[CAItem alloc] initWithDictionary:response];
            success(item);
        }
    } failure:failure];
}

- (void)createBookmarkWithName:(NSString *)name url:(NSURL *)url success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] postRequestWithURL:[CANetworkManager secureUrlWithExtension:itemsExtension]
                                                     body:@{kItem: @{kName:name, kRedirectURL:url.absoluteString}}
                                               completion:[self completionBlockForItemWithSuccess:success failure:failure]];
}

- (void)createBookmarks:(NSArray<NSDictionary *> *)bookmarks success:(void (^)(NSArray<CAItem *> *items))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] postRequestWithURL:[CANetworkManager secureUrlWithExtension:itemsExtension]
                                                     body:@{kItem: bookmarks}
                                               completion:[self completionBlockForItemsWithSuccess:success failure:failure]];
}

- (void)setItem:(CAItem *)item isPrivate:(BOOL)private success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] putRequestWithURL:[[CANetworkManager secureUrlWithExtension:itemsExtension] URLByAppendingPathExtension:[@(item.uniqueId) stringValue]]
                                                    body:@{kItem: @{kPrivate: @(private)}}
                                              completion:[self completionBlockForItemUpdate:item success:success failure:failure]];
}

- (void)deleteItem:(CAItem *)item success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] deleteRequestWithURL:[[CANetworkManager secureUrlWithExtension:itemsExtension] URLByAppendingPathExtension:[@(item.uniqueId) stringValue]]
                                                 completion:[self completionBlockForItemUpdate:item success:success failure:failure]];
}

- (void)recoverItem:(CAItem *)item success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] putRequestWithURL:[[CANetworkManager secureUrlWithExtension:itemsExtension] URLByAppendingPathExtension:[@(item.uniqueId) stringValue]]
                                                    body:@{kDeleted: @(true), kItem: @{kDeletedAt: @"null"}}
                                              completion:[self completionBlockForItemUpdate:item success:success failure:failure]];
}

- (void)renameItem:(CAItem *)item name:(NSString *)name success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure {
    [[CANetworkManager sharedInstance] putRequestWithURL:[[CANetworkManager secureUrlWithExtension:itemsExtension] URLByAppendingPathExtension:[@(item.uniqueId) stringValue]]
                                                    body:@{kItem: @{kName: name}}
                                              completion:[self completionBlockForItemUpdate:item success:success failure:failure]];
}

@end
