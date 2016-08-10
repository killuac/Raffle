//
//  UIViewController+Base.h
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright (c) 2015 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KLViewControllerProtocol <KLViewProtocol>

@optional
- (instancetype)initWithViewModel:(id)viewModel;

- (void)prepareForUI;
- (void)setupNavigationBar;

- (void)loadData;
- (void)loadData:(KLVoidBlockType)completion;
- (void)reloadData;
- (void)refreshUI;

@end


@interface UIViewController (Base) <KLViewControllerProtocol, UITextFieldDelegate>

+ (instancetype)viewControllerWithViewModel:(id)viewModel;

@property (nonatomic, assign) BOOL isLoadingData;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong, readonly) UITabBar *tabBar;
@property (nonatomic, strong, readonly) UINavigationBar *navigationBar;
@property (nonatomic, strong, readonly) UIViewController *rootViewController;
@property (nonatomic, strong, readonly) UIViewController *visibleViewController;

@property (nonatomic, assign, readonly) CGFloat statusBarHeight;
@property (nonatomic, assign, readonly) CGFloat navigationBarHeight;
@property (nonatomic, assign, readonly) CGFloat tabBarHeight;

- (void)showInitialViewController;
- (void)showMainViewController;

@end
