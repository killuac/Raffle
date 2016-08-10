//
//  UIView+Base.h
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright (c) 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN const CGFloat KLViewDefaultMargin;
UIKIT_EXTERN const CGFloat KLViewDefaultHeight;
UIKIT_EXTERN const CGFloat KLViewDefaultButtonHeight;
UIKIT_EXTERN const CGFloat KLViewDefaultCornerRadius;
UIKIT_EXTERN const NSTimeInterval KLViewDefaultAnimationDuration;


@protocol KLViewProtocol <NSObject>

@optional
- (void)addSubviews;
- (void)addSubviews:(NSArray *)subviews;

- (void)addTapGesture;
- (void)removeTapGesture;
- (void)singleTap:(UITapGestureRecognizer *)recognizer;

- (void)addObservers;

@end


@interface UIView (Base) <KLViewProtocol>

+ (instancetype)newAutoLayoutView;
- (void)constraintsEqualWithSuperView;
- (void)constraintsEqualWidthWithSuperView;
- (void)constraintsEqualHeightWithSuperView;
- (void)constraintsEqualWidthAndHeight;
- (void)constraintsCenterInSuperview;
- (void)constraintsCenterXWithView:(UIView *)view;
- (void)constraintsCenterYWithView:(UIView *)view;

@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign, readonly) CGFloat intrinsicContentWidth;
@property (nonatomic, assign, readonly) CGFloat intrinsicContentHeight;

@property (nonatomic, assign, readonly) CGFloat statusBarHeight;
@property (nonatomic, strong, readonly) UIViewController *viewController;

@property (nonatomic, strong, readonly) UITableView *superTableView;
@property (nonatomic, strong, readonly) UICollectionView *superCollectionView;

@property (nonatomic, strong, readonly) UITableViewCell *superTableViewCell;
@property (nonatomic, strong, readonly) UICollectionViewCell *superCollectionViewCell;

@property (nonatomic, strong, readonly) UITableView *subTableView;
@property (nonatomic, strong, readonly) UICollectionView *subCollectionView;

// Avoid off-screen rendered
- (void)setCornerRadius:(CGFloat)radius;  // by UIRectCornerAllCorners
- (void)setCornerRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor *)color;
- (void)setCornerRadius:(CGFloat)radius byRoundingCorners:(UIRectCorner)corners;
- (void)setCornerRadius:(CGFloat)radius byRoundingCorners:(UIRectCorner)corners borderWidth:(CGFloat)width borderColor:(UIColor *)color;

- (void)findAndResignFirstResponder;

- (void)addBlurBackground;
- (void)removeBlurBackground;

+ (void)animateWithDefaultDuration:(KLVoidBlockType)animations;
+ (void)animateWithDefaultDuration:(KLVoidBlockType)animations completion:(void (^)(BOOL finished))completion;
+ (void)animateSpringWithDefaultDuration:(KLVoidBlockType)animations;
+ (void)animateSpringWithDefaultDuration:(KLVoidBlockType)animations completion:(void (^)(BOOL finished))completion;
- (void)animateSpringScale;

@end
