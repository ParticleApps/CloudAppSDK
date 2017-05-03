//
//  CAObjectPrivate.h
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CAObject.h"

@interface CAObject ()

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (BOOL)updateWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)preprocessDictionary:(NSDictionary *)dictionary;

@end
