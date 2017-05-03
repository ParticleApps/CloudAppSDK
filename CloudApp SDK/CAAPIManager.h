//
//  CAAPIManager.h
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/2/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CAItem.h"

extern NSString *const bookmarkNameKey;
extern NSString *const bookmarkURLKey;

@interface CAAPIManager : NSObject

@property (nonatomic) NSInteger defaultItemsPerPage;

+ (instancetype)sharedInstance;

//Fetch
- (void)fetchItemsAtPage:(NSInteger)page success:(void (^)(NSArray<CAItem *> *items))success failure:(void (^)(NSError *error))failure;

- (void)fetchItemsAtPage:(NSInteger)page
    numberOfItemsPerPage:(NSInteger)numberOfItems
                    type:(CAItemType)type
                 success:(void (^)())success
                 failure:(void (^)(NSError *error))failure;

- (void)fetchArchivedItemsAtPage:(NSInteger)page success:(void (^)())success failure:(void (^)(NSError *error))failure;

- (void)fetchArchievedItemsAtPage:(NSInteger)page
             numberOfItemsPerPage:(NSInteger)numberOfItems
                             type:(CAItemType)type
                          success:(void (^)())success
                          failure:(void (^)(NSError *error))failure;

- (void)fetchHomePageForDomain:(NSString *)domain success:(void (^)(NSString *homepage))success failure:(void (^)(NSError *error))failure;

//Actions
- (void)createBookmarkWithName:(NSString *)name url:(NSURL *)url success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

- (void)createBookmarks:(NSArray<NSDictionary *> *)bookmarks success:(void (^)(NSArray<CAItem *> *items))success failure:(void (^)(NSError *error))failure;

- (void)setItem:(CAItem *)item isPrivate:(BOOL)private success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

- (void)deleteItem:(CAItem *)item success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

- (void)recoverItem:(CAItem *)item success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

- (void)renameItem:(CAItem *)item name:(NSString *)name success:(void (^)(CAItem *item))success failure:(void (^)(NSError *error))failure;

@end
