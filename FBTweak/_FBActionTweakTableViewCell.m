/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweak.h"
#import "_FBActionTweakTableViewCell.h"

@implementation _FBActionTweakTableViewCell

@synthesize tweak = _tweak;

/// Block to execute when a key path value has changed. The block provides the \c cell to update and
/// the observed \c value that should be updated in \c cell. The block is always called on the main
/// thread.
typedef void (^FBActionTweakTableViewCellBlock)(_FBActionTweakTableViewCell *cell, id value);

+ (NSDictionary<NSString *, FBActionTweakTableViewCellBlock> *)keyPathMapping {
  return @{
    @"tweak.isEnabled": ^(_FBTweakTableViewCell *cell, NSNumber *value) {
      cell.textLabel.enabled = value.boolValue;
      cell.userInteractionEnabled = value.boolValue;
    },
    @"tweak.name": ^(_FBTweakTableViewCell *cell, id value) {
      if ([value isKindOfClass:[NSString class]]) {
        cell.textLabel.text = value;
      }
    }
  };
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])) {
    self.detailTextLabel.hidden = YES;
    self.textLabel.textColor = self.tintColor;
    for (NSString *keyToObserve in [[self class] keyPathMapping]) {
      [self addObserver:self forKeyPath:keyToObserve
                options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                context:nil];
    }
  }

  return self;
}

- (void)dealloc {
  for (NSString *keyToRemove in [[self class] keyPathMapping]) {
    [self removeObserver:self forKeyPath:keyToRemove];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(_FBTweakTableViewCell *)cell
                        change:(NSDictionary *)change context:(void *)context {
  FBActionTweakTableViewCellBlock _Nullable block = [[self class] keyPathMapping][keyPath];
  if (!block) {
    return;
  }

  id value = [self valueForKeyPath:keyPath];
  dispatch_async(dispatch_get_main_queue(), ^{
    block(self, value);
  });
}

@end
