// Copyright (c) 2018 Lightricks. All rights reserved.
// Created by Yonatan Oren.

#import "FBTweaksDisplayUtils.h"

@implementation FBTweaksDisplayUtils

+ (NSString *)simpleLocalFormattedDate:(NSDate *)date {
  NSDateFormatter *localFormatter = [[NSDateFormatter alloc] init];
  [localFormatter setTimeZone:[NSTimeZone localTimeZone]];
  [localFormatter setDateFormat:@"HH:mm:ss dd/MMM/yy zzz"];
  return [localFormatter stringFromDate:date];
}

@end

