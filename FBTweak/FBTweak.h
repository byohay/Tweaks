/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
  @abstract Represents a possible value of a tweak.
  @discussion Should be able to be persisted in user defaults,
    except actions (represented as blocks without a currentValue).
    For minimum and maximum values, should implement -compare:.
 */
typedef id FBTweakValue;

/**
  @abstract Represents a range of values for a numeric tweak.
  @discussion Use this for the -possibleValues on a tweak.
 */
@interface FBTweakNumericRange : NSObject <NSCoding>

/**
  @abstract Creates a new numeric range.
  @discussion This is the designated initializer.
  @param minimumValue The minimum value of the range.
  @param maximumValue The maximum value of the range.
 */
- (instancetype)initWithMinimumValue:(FBTweakValue)minimumValue maximumValue:(FBTweakValue)maximumValue;

/**
  @abstract The minimum value of the range.
  @discussion Will always have a value.
 */
@property (readwrite, nonatomic) FBTweakValue minimumValue;

/**
  @abstract The maximum value of the range.
  @discussion Will always have a value.
 */
@property (readwrite, nonatomic) FBTweakValue maximumValue;

@end

/**
 @abstract Represents a single value that can be updated, and monitored using KVO.
 */
@protocol FBTweak <NSObject>

/**
 @abstract This tweak's unique identifier.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 @abstract The human-readable name of the tweak.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 @abstract The current value of the tweak. KVO-compliant.
 */
@property (readonly ,nonatomic, nullable) FBTweakValue currentValue;

@optional

/**
 @abstract Reset the tweak to its initial state.
 */
- (void)reset;

@end

/**
 @abstract A tweak that contains a block as its \c currentValue.
 */
@protocol FBActionTweak <FBTweak>

/**
 @abstract The underlying block for this tweak.
 */
@property (readonly ,nonatomic) dispatch_block_t currentValue;

/**
 @abstract If \c NO the block is not allowed to be called.
 */
@property (nonatomic) BOOL isEnabled;

@end

/**
 @abstract Represent an editable \c FBTweak, whose \c currentValue can be set.
 */
@protocol FBEditableTweak <FBTweak>

/**
 @abstract Reset the tweak to its initial state.
 */
- (void)reset;

/**
 @abstract The current value of the tweak.
 */
@property (readwrite, nonatomic, nullable) FBTweakValue currentValue;

/**
 @abstract The default value of the tweak. It is up to the user whether to use this value when the
 \c currentValue is \c nil.
 */
@property (readonly ,nonatomic) FBTweakValue defaultValue;

/**
 @abstract The possible values of the tweak.
 @discussion If \c nil, any value is allowed. If an FBTweakNumericRange, represents a range of
 numeric values. If \c NSSArray contains all of the allowed values. If \c NSDictionary, the keys are
 the allowed values for \c currentValues, and the values are the display name for each allowed
 value.
 */
@property (readwrite, nonatomic, nullable) id possibleValues;

/**
 @abstract The minimum value of the tweak.
 @discussion If \c nil, there is no minimum. Applicable when \c currentValue contains only numeric
 values.
 */
@property (readwrite, nonatomic, nullable) FBTweakValue minimumValue;

/**
 @abstract The maximum value of the tweak.
 @discussion If \c nil, there is no maximum. Applicable when \c currentValue contains only numeric
 values.
 */
@property (readwrite, nonatomic, nullable) FBTweakValue maximumValue;

/**
 @abstract The step value of the tweak.
 @discussion If \c nil, a default value will be used. Applicable when \c currentValue contains only
 numeric values.
 */
@property (readwrite, nonatomic, nullable) FBTweakValue stepValue;

/**
 @abstract The decimal precision value of the tweak.
 @discussion If \c nil, a default value will be used. Applicable when \c currentValue contains only
 numeric values.
 */
@property (readwrite, nonatomic, nullable) FBTweakValue precisionValue;

@end

/**
 @abstract An immutable tweak.
 */
@interface FBTweak : NSObject <FBTweak>

- (instancetype)init NS_UNAVAILABLE;

/**
 @abstract Initializes with the given \c name, \c identifier and \c currentValue.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name
                      currentValue:(FBTweakValue)currentValue NS_DESIGNATED_INITIALIZER;

@end

/**
 @abstract A tweak with an underlying block.
 */
@interface FBActionTweak : NSObject <FBActionTweak>

- (instancetype)init NS_UNAVAILABLE;

/**
 @abstract Initializes with \c identifier, \c name and \c block as the underlying block.
 The \c currentValue property of the tweak is set to be the \c block and \c isEnabled is set to
 \c YES.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name
                             block:(dispatch_block_t)block NS_DESIGNATED_INITIALIZER;

@end

/**
  @abstract The default implementation for \c FBEditableTweak.
 */
@interface FBMutableTweak : NSObject <FBEditableTweak>

- (instancetype)init NS_UNAVAILABLE;

/**
 @abstract Initializes with the given \c name, \c identifier and \c defaultValue.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name
                      defaultValue:(FBTweakValue)defaultValue NS_DESIGNATED_INITIALIZER;

@end

/**
 @abstract Mutable tweak which persistently stores its \c currentValue whenever it changes.
 Upon initialization, the current value is reloaded from the persistent storage, using the
 \c identifier as the key.
 */
@interface FBPersistentTweak : FBMutableTweak
@end

NS_ASSUME_NONNULL_END
