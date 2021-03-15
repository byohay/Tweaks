/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweak.h"

#import <UIKit/UIKit.h>

@implementation FBTweakNumericRange

- (instancetype)initWithMinimumValue:(FBTweakValue)minimumValue maximumValue:(FBTweakValue)maximumValue
{
  if ((self = [super init])) {
    NSParameterAssert(minimumValue != nil);
    NSParameterAssert(maximumValue != nil);

    _minimumValue = minimumValue;
    _maximumValue = maximumValue;
  }

  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  FBTweakValue minimumValue = [coder decodeObjectForKey:@"minimumValue"];
  FBTweakValue maximumValue = [coder decodeObjectForKey:@"maximumValue"];
  self = [self initWithMinimumValue:minimumValue maximumValue:maximumValue];

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:_minimumValue forKey:@"minimumValue"];
  [coder encodeObject:_maximumValue forKey:@"maximumValue"];
}

@end

@implementation FBTweak

@synthesize name = _name;
@synthesize identifier = _identifier;
@synthesize currentValue = _currentValue;

- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name
                      currentValue:(FBTweakValue)currentValue {
  if (self = [super init]) {
    _identifier = identifier;
    _name = name;
    _currentValue = currentValue;
  }
  return self;
}

@end

@implementation FBActionTweak

@synthesize name = _name;
@synthesize identifier = _identifier;
@synthesize currentValue = _currentValue;
@synthesize isEnabled = _isEnabled;

- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name
                             block:(dispatch_block_t)block {
  if (self = [super init]) {
    _identifier = identifier;
    _name = name;
    _currentValue = block;
    _isEnabled = YES;
    __weak typeof(self) weakSelf = self;
    _currentValue = ^{
      __strong typeof(self) self = weakSelf;
      if (!self) {
        return;
      }
      NSAssert(self.isEnabled, @"FBActionTweak block called while the tweak is not enabled");
      block();
    };
  }
  return self;
}

@end

@implementation FBMutableTweak

@synthesize name = _name;
@synthesize identifier = _identifier;
@synthesize currentValue = _currentValue;
@synthesize defaultValue = _defaultValue;
@synthesize possibleValues = _possibleValues;
@synthesize precisionValue = _precisionValue;
@synthesize stepValue = _stepValue;

- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name
                      defaultValue:(FBTweakValue)defaultValue {
  if (self = [super init]) {
    _identifier = identifier;
    _name = name;
    _defaultValue = defaultValue;
  }

  return self;
}

- (FBTweakValue)minimumValue
{
  if ([_possibleValues isKindOfClass:[FBTweakNumericRange class]]) {
    return [(FBTweakNumericRange *)_possibleValues minimumValue];
  } else {
    return nil;
  }
}

- (void)setMinimumValue:(FBTweakValue)minimumValue
{
  if (minimumValue == nil) {
    _possibleValues = nil;
  } else if ([_possibleValues isKindOfClass:[FBTweakNumericRange class]]) {
    _possibleValues = [[FBTweakNumericRange alloc] initWithMinimumValue:minimumValue maximumValue:[(FBTweakNumericRange *)_possibleValues maximumValue]];
  } else {
    _possibleValues = [[FBTweakNumericRange alloc] initWithMinimumValue:minimumValue maximumValue:minimumValue];
  }
}

- (FBTweakValue)maximumValue
{
  if ([_possibleValues isKindOfClass:[FBTweakNumericRange class]]) {
    return [(FBTweakNumericRange *)_possibleValues maximumValue];
  } else {
    return nil;
  }
}

- (void)setMaximumValue:(FBTweakValue)maximumValue
{
  if (maximumValue == nil) {
    _possibleValues = nil;
  } else if ([_possibleValues isKindOfClass:[FBTweakNumericRange class]]) {
    _possibleValues = [[FBTweakNumericRange alloc] initWithMinimumValue:[(FBTweakNumericRange *)_possibleValues minimumValue] maximumValue:maximumValue];
  } else {
    _possibleValues = [[FBTweakNumericRange alloc] initWithMinimumValue:maximumValue maximumValue:maximumValue];
  }
}

- (void)setCurrentValue:(FBTweakValue)currentValue
{
  if (_possibleValues != nil && currentValue != nil) {
    if ([_possibleValues isKindOfClass:[NSArray class]]) {
      if ([_possibleValues indexOfObject:currentValue] == NSNotFound) {
        currentValue = self.defaultValue;
      }
    } else if ([_possibleValues isKindOfClass:[NSDictionary class]]) {
      if ([[_possibleValues allKeys] indexOfObject:currentValue] == NSNotFound) {
        currentValue = self.defaultValue;
      }
    } else {
      FBTweakValue minimumValue = self.minimumValue;
      if (self.minimumValue != nil && currentValue != nil && [minimumValue compare:currentValue] == NSOrderedDescending) {
        currentValue = minimumValue;
      }

      FBTweakValue maximumValue = self.maximumValue;
      if (maximumValue != nil && currentValue != nil && [maximumValue compare:currentValue] == NSOrderedAscending) {
        currentValue = maximumValue;
      }
    }
  }

  if (_currentValue != currentValue) {
    _currentValue = currentValue;
  }
}

- (void)reset {
  self.currentValue = nil;
}

@end

@implementation FBPersistentTweak

- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name
                      defaultValue:(FBTweakValue)defaultValue {
  if (self = [super initWithIdentifier:identifier name:name defaultValue:defaultValue]) {
    id currentValue;
    NSData *archivedValue = [[NSUserDefaults standardUserDefaults] objectForKey:identifier];
    if (archivedValue != nil && [archivedValue isKindOfClass:[NSData class]]) {
      currentValue =
          [NSKeyedUnarchiver unarchivedObjectOfClasses:[FBPersistentTweak validValueClasses]
                                              fromData:archivedValue error:nil];
    } else {
      currentValue = archivedValue;
    }

    // Using \c class instead of \c classForKeyedArchiver might lead to unexpected behaviour because
    // defaultValue might be a hidden class like \c NSTaggedPointerString, in which case the check
    // will fail. \c classForKeyedArchiver will return the class we want to check against.
    if (!self.defaultValue ||
        [currentValue isKindOfClass:[self.defaultValue classForKeyedArchiver]]) {
      self.currentValue = currentValue;
    }
  }

  return self;
}

- (void)setCurrentValue:(FBTweakValue)currentValue {
  [super setCurrentValue:currentValue];

  // we can't store UIColor to the plist file. That is why we archive value to the NSData.
  NSError *error;
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.currentValue
                                       requiringSecureCoding:YES error:&error];
  NSAssert(data != nil, @"Failed to archive value with error: %@", error);
  [[NSUserDefaults standardUserDefaults] setObject:data forKey:self.identifier];
}

+ (NSSet<Class> *)validValueClasses {
  return [NSSet setWithArray:@[
    [NSData class],
    [NSString class],
    [NSNumber class],
    [NSDate class],
    [NSArray class],
    [NSDictionary class],
    [UIColor class]
  ]];
}

@end
