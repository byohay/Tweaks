/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweak.h"
#import "FBTweakCategory.h"
#import "FBTweakCollection.h"
#import "_FBActionTweakTableViewCell.h"
#import "_FBEditableTweakArrayViewController.h"
#import "_FBEditableTweakColorViewController.h"
#import "_FBEditableTweakDictionaryViewController.h"
#import "_FBEditableTweakTableViewCell.h"
#import "_FBKeyboardManager.h"
#import "_FBTweakCollectionViewController.h"
#import "_FBTweakTableViewCell.h"
#import "_FBEditableTweakDateViewController.h"
#import "_FBEditableTweakStringViewController.h"

@implementation _FBTweakCollectionViewController {
  _FBKeyboardManager *_keyboardManager;
}

- (instancetype)initWithTweakCategory:(FBTweakCategory *)category
{
  if ((self = [super init])) {
    _tweakCategory = category;
    self.title = _tweakCategory.name;

    [(id)self.tweakCategory addObserver:self forKeyPath:NSStringFromSelector(@selector(tweakCollections))
                                options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                context:nil];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(_updateCategory)
                  forControlEvents:UIControlEventValueChanged];

    [self.tableView registerClass:[_FBEditableTweakTableViewCell class]
           forCellReuseIdentifier:NSStringFromClass([_FBEditableTweakTableViewCell class])];
    [self.tableView registerClass:[_FBActionTweakTableViewCell class]
           forCellReuseIdentifier:NSStringFromClass([_FBActionTweakTableViewCell class])];
    [self.tableView registerClass:[_FBTweakTableViewCell class]
           forCellReuseIdentifier:NSStringFromClass([_FBTweakTableViewCell class])];
  }
  
  return self;
}

- (Class)tweakCellForTweak:(id<FBTweak>)tweak {
  if ([tweak conformsToProtocol:@protocol(FBActionTweak)]) {
    return [_FBActionTweakTableViewCell class];
  } else if ([self editableTweak:tweak]) {
    return [_FBEditableTweakTableViewCell class];
  }
  return [_FBTweakTableViewCell class];
}

- (BOOL)editableTweak:(id<FBTweak>)tweak {
  return [tweak conformsToProtocol:@protocol(FBEditableTweak)] &&
      ((id<FBEditableTweak>)tweak).editableFromUI;
}

- (void)dealloc
{
  [(id)self.tweakCategory removeObserver:self
                              forKeyPath:NSStringFromSelector(@selector(tweakCollections))];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSArray<FBTweakCollection *> *)tweakCollections change:(NSDictionary *)change context:(void *)context
{
  if (![keyPath isEqualToString:NSStringFromSelector(@selector(tweakCollections))]) {
    return;
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    [self _reloadData];
  });
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_done)];

  _keyboardManager = [[_FBKeyboardManager alloc] initWithViewScrollView:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [self _reloadData];

  [_keyboardManager enable];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [_keyboardManager disable];
}

- (void)_updateCategory {
  self.refreshControl.attributedTitle =
      [[NSAttributedString alloc] initWithString:@"Refreshing..."];
  [self.refreshControl beginRefreshing];
  [self.tweakCategory updateWithCompletion:^(NSError * _Nullable error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        if (error) {
          [self presentViewController:[self errorAlertControllerWithError:error] animated:YES
                           completion:nil];
        }
      });
    }];
}

- (UIAlertController *)errorAlertControllerWithError:(NSError * _Nonnull)error {
  NSString *alertMessage = [NSString stringWithFormat:@"An error occured while updating: %@.",
                            error.description];
  UIAlertController *alertController = [UIAlertController
                                        alertControllerWithTitle:@"Error updating catergory"
                                        message:alertMessage
                                        preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *okAction = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction __unused *action){}];

  [alertController addAction:okAction];
  return alertController;
}

- (void)_reloadData
{
  [self.tableView reloadData];
}

- (void)_done
{
  [_delegate tweakCollectionViewControllerSelectedDone:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.tweakCategory.tweakCollections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  FBTweakCollection *collection = self.tweakCategory.tweakCollections[section];
  return collection.tweaks.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  FBTweakCollection *collection = self.tweakCategory.tweakCollections[section];
  return collection.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  FBTweakCollection *collection = self.tweakCategory.tweakCollections[indexPath.section];
  id<FBTweak> tweak = collection.tweaks[indexPath.row];

  NSString *reusableIdentifier = NSStringFromClass([self tweakCellForTweak:tweak]);
  UITableViewCell<_FBTweakContainer> *cell = [tableView dequeueReusableCellWithIdentifier:reusableIdentifier];
  cell.tweak = tweak;

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  FBTweakCollection *collection = self.tweakCategory.tweakCollections[indexPath.section];
  id<FBTweak> tweak = collection.tweaks[indexPath.row];

  if ([tweak conformsToProtocol:@protocol(FBActionTweak)]) {
    FBActionTweak *actionTweak = (FBActionTweak *)tweak;
    dispatch_block_t _Nullable block = actionTweak.currentValue;
    if (block != NULL) {
      block();
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  } else if ([self editableTweak:tweak]) {
    id<FBEditableTweak> editableTweak = (id<FBEditableTweak>)tweak;
    if ([editableTweak.possibleValues isKindOfClass:[NSDictionary class]]) {
      _FBEditableTweakDictionaryViewController *vc = [[_FBEditableTweakDictionaryViewController alloc] initWithEditableTweak:editableTweak];
      [self.navigationController pushViewController:vc animated:YES];
    } else if ([editableTweak.possibleValues isKindOfClass:[NSArray class]]) {
      _FBEditableTweakArrayViewController *vc = [[_FBEditableTweakArrayViewController alloc] initWithEditableTweak:editableTweak];
      [self.navigationController pushViewController:vc animated:YES];
    } else if ([editableTweak.defaultValue isKindOfClass:[UIColor class]]) {
      _FBEditableTweakColorViewController *vc = [[_FBEditableTweakColorViewController alloc] initWithEditableTweak:editableTweak];
      [self.navigationController pushViewController:vc animated:YES];
    } else if ([editableTweak.defaultValue isKindOfClass:[NSDate class]]) {
      _FBEditableTweakDateViewController *vc = [[_FBEditableTweakDateViewController alloc] initWithEditableTweak:editableTweak];
      [self.navigationController pushViewController:vc animated:YES];
    } else if ([editableTweak.defaultValue isKindOfClass:[NSString class]]) {
      _FBEditableTweakStringViewController *vc = [[_FBEditableTweakStringViewController alloc]
          initWithEditableTweak:editableTweak];
      [self.navigationController pushViewController:vc animated:YES];
    }
  } else {
    // Other FBTweak objects are read-only
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
}

@end
