//
//  UIViewController+Base.h
//  Raffle
//
//  Created by Killua Liu on 12/16/15.
//  Copyright (c) 2015 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KLViewControllerProtocol <KLViewProtocol>

@optional
- (instancetype)initWithDataController:(id)dataController;

- (void)prepareForUI;
- (void)setupNavigationBar;

- (void)loadData;
- (void)loadData:(KLVoidBlockType)completion;
- (void)reloadData;
- (void)refreshUI;

@end


@class KLBaseTransition;

@interface UIViewController (Base) <KLViewControllerProtocol, UITextFieldDelegate>

+ (instancetype)viewController;
+ (instancetype)viewControllerWithDataController:(id)dataController;

@property (nonatomic, strong) KLBaseTransition *transition;
@property (nonatomic, copy) KLDismissBlockType dismissBlock;

@property (nonatomic, weak, readonly) UITabBar *tabBar;
@property (nonatomic, weak, readonly) UINavigationBar *navigationBar;
@property (nonatomic, weak, readonly) UIViewController *rootViewController;
@property (nonatomic, weak, readonly) UIViewController *visibleViewController;

@property (nonatomic, readonly) CGFloat statusBarHeight;
@property (nonatomic, readonly) CGFloat navigationBarHeight;
@property (nonatomic, readonly) CGFloat tabBarHeight;

- (void)showInitialViewController;
- (void)showMainViewController;

@end
