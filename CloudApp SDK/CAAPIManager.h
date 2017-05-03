//
//  CAAPIManager.h
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/2/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CAItem.h"

@interface CAAPIManager : NSObject

@property (nonatomic) NSInteger defaultItemsPerPage;

+ (instancetype)sharedInstance;

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

@end
