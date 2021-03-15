/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

#import "FBTweak.h"
#import "_FBTweakTableViewCell.h"

@class FBActionTweak;

/**
 @abstract A table cell to show a actionable tweak.
 @discussion Contains a single clickable label.
 */
@interface _FBActionTweakTableViewCell : UITableViewCell <_FBTweakContainer>

//! @abstract The tweak to show in the cell.
@property (nonatomic, strong, readwrite) id<FBActionTweak> tweak;

@end

