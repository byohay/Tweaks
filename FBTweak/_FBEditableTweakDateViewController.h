/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FBTweak.h"

/// Date picker for FBTweaks, shows a single \c UIDatePicker, upon choosing a date it is set as
/// the \c FBTweak.value .
@interface _FBEditableTweakDateViewController : UIViewController

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/// Initializes with the given \c tweak and uses its value as the date for the date picker. When
/// the user changes the date in the picker the tweak value is changed.
- (instancetype)initWithEditableTweak:(id<FBEditableTweak>)tweak NS_DESIGNATED_INITIALIZER;

/// The underlying tweak.
@property (nonatomic, readonly) id<FBEditableTweak> tweak;

@end
