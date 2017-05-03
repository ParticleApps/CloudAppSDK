//
//  CAItemPrivate.h
//  CloudApp SDK
//
//  Created by Rocco Del Priore on 5/2/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

#import "CAItem.h"

@interface CAItem ()
+ (CAItemType)typeForAPIValue:(NSString *)value;
+ (NSString *)apiValueForItemType:(CAItemType)type;
@end
