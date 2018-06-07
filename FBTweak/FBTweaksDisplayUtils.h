// Copyright (c) 2018 Lightricks. All rights reserved.
// Created by Yonatan Oren.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBTweaksDisplayUtils : NSObject

/// Convert a date to a short formatted string in the device's timezone.
+ (NSString *)simpleLocalFormattedDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
