//
//  PSTCKRSA.h
//  Paystack
//
//  Created by Ibrahim Lawal on Feb/27/2016.
//  Copyright © 2016 Paystack, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface PSTCKRSA : NSObject
+ (nullable NSString *)encryptRSA:(nonnull NSString *)plainTextString;
@end

