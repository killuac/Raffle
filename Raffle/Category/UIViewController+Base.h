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


@interface UIViewController (Base) <KLViewControllerProtocol, UITextFieldDelegate>

+ (instancetype)viewController;
+ (instancetype)viewControllerWithDataController:(id)dataController;

@property (nonatomic, copy) KLDismissBlockType dismissBlock;

@property (nonatomic, readonly) UITabBar *tabBar;
@property (nonatomic, readonly) UINavigationBar *navigationBar;
@property (nonatomic, readonly) UIViewController *rootViewController;
@property (nonatomic, readonly) UIViewController *visibleViewController;

@property (nonatomic, readonly) CGFloat statusBarHeight;
@property (nonatomic, readonly) CGFloat navigationBarHeight;
@property (nonatomic, readonly) CGFloat tabBarHeight;

- (void)showInitialViewController;
- (void)showMainViewController;

@end
