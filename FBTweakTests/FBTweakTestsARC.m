/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>

#import "FBTweak.h"
#import "FBTweakStore.h"

#if !__has_feature(objc_arc)
#error ARC is required.
#endif

@interface FBTweakTestsARC : XCTestCase

@end

@implementation FBTweakTestsARC

- (void)setUp
{
    [[FBTweakStore sharedInstance] reset];
}

- (void)testPersistence
{
  @autoreleasepool {
    FBPersistentTweak *stringTweak = [[FBPersistentTweak alloc] initWithIdentifier:@"foo" name:@"bar" defaultValue:@"baz"];
    XCTAssertEqualObjects(stringTweak.defaultValue, @"baz");

    stringTweak.currentValue = @"bazie";
  }

  @autoreleasepool {
    FBPersistentTweak *otherStringTweak = [[FBPersistentTweak alloc] initWithIdentifier:@"foo" name:@"bar" defaultValue:@"baz"];
    XCTAssertEqualObjects(otherStringTweak.currentValue, @"bazie", @"Tweak default value %@", otherStringTweak.defaultValue);
  }

  @autoreleasepool {
    FBPersistentTweak *otherTypeTweak = [[FBPersistentTweak alloc] initWithIdentifier:@"foo" name:@"bar" defaultValue:[UIColor blackColor]];
    XCTAssertEqualObjects(otherTypeTweak.currentValue, nil, @"Tweak default value %@", otherTypeTweak.defaultValue);
  }
}

@end

