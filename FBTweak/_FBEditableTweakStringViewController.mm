/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBEditableTweakStringViewController.h"

@interface _FBEditableTweakStringViewController ()

/// The text view.
@property(readonly, nonatomic) UITextView *textView;

@end

@implementation _FBEditableTweakStringViewController {}

- (instancetype)initWithEditableTweak:(id<FBEditableTweak>)tweak {
  if ((self = [super initWithNibName:nil bundle:nil])) {
    _tweak = tweak;
    self.title = _tweak.name;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  [self setupTextView];
}

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  self.tweak.currentValue = self.textView.text;
}

- (void)setupTextView {
  _textView = [[UITextView alloc] initWithFrame:self.view.bounds];
  self.textView.text = self.tweak.currentValue ?: self.tweak.defaultValue;
  [self.textView setFont:[UIFont systemFontOfSize:20]];
  [self.view addSubview:self.textView];
  [self.textView becomeFirstResponder];
}

@end
