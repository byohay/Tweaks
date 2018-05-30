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

/// String editor for FBTweaks, shows a single \c UITextView, upon dismissal value is set in the
/// tweak.
@interface _FBEditableTweakStringViewController : UIViewController

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/// Initializes with the given \c tweak and uses its value as the text for \c UITextView.
- (instancetype)initWithEditableTweak:(id<FBEditableTweak>)tweak NS_DESIGNATED_INITIALIZER;

/// The underlying tweak.
@property (nonatomic, readonly) id<FBEditableTweak> tweak;

@end
