//
//  UIView+Base.m
//  Raffle
//
//  Created by Killua Liu on 12/16/15.
//  Copyright (c) 2016 Syzygy. All rights reserved.
//

#import "UIView+Base.h"

const CGFloat KLViewDefaultMargin = 16.0f;
const CGFloat KLViewDefaultHeight = 44.0f;
const CGFloat KLViewDefaultButtonHeight = 40.0f;
const CGFloat KLViewDefaultCornerRadius = 5.0f;

@implementation UIView (Base)

const CGFloat kBackgroundViewTag = 9999;

- (void)addSubviews:(NSArray *)subviews
{
    [subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [self addSubview:view];
    }];
}

- (CGFloat)statusBarHeight
{
    return CGRectGetHeight(UIApplication.sharedApplication.statusBarFrame);
}

- (id)viewController
{
    for (UIView *view = self.superview; view; view = view.superview) {
        UIResponder* nextResponder = view.nextResponder;
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return nextResponder;
        }
    }
    
    return nil;
}

#pragma mark - Autolayout
+ (instancetype)newAutoLayoutView
{
    UIView *view = [[self alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

- (void)constraintsEqualWithSuperView
{
    NSDictionary *views = NSDictionaryOfVariableBindings(self);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[self]|" views:views]];
}

- (void)constraintsEqualWidthWithSuperView
{
    NSDictionary *views = NSDictionaryOfVariableBindings(self);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" views:views]];
}

- (void)constraintsEqualHeightWithSuperView
{
    NSDictionary *views = NSDictionaryOfVariableBindings(self);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[self]|" views:views]];
}

- (void)constraintsEqualWidthAndHeight
{
    [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                    toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0].active = YES;
}

- (void)constraintsCenterInSuperview
{
    [NSLayoutConstraint constraintCenterXWithItem:self].active = YES;
    [NSLayoutConstraint constraintCenterYWithItem:self].active = YES;
}

- (void)constraintsCenterXWithView:(UIView *)view
{
    [NSLayoutConstraint constraintCenterXWithItem:self toItem:view].active = YES;
}

- (void)constraintsCenterYWithView:(UIView *)view
{
    [NSLayoutConstraint constraintCenterYWithItem:self toItem:view].active = YES;
}

- (void)constraintsTopLayoutGuide
{
    [NSLayoutConstraint constraintTopWithItem:self toTopLayoutGuide:self.viewController.topLayoutGuide].active = YES;
}

- (void)constraintsBottomLayoutGuide
{
    [NSLayoutConstraint constraintBottomWithItem:self toBottomLayoutGuide:self.viewController.bottomLayoutGuide].active = YES;
}

#pragma mark - Left/Right/Top/Bottom
- (CGFloat)left
{
    return CGRectGetMinX(self.frame);
}

- (void)setLeft:(CGFloat)left
{
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (CGFloat)right
{
    return self.left + self.width;
}

- (void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - self.width;
    self.frame = frame;
}

- (CGFloat)top
{
    return CGRectGetMinY(self.frame);
}

- (void)setTop:(CGFloat)top
{
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (CGFloat)bottom
{
    return self.top + self.height;
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - self.height;
    self.frame = frame;
}

#pragma mark - Center
- (CGFloat)centerX
{
    return CGRectGetMidX(self.frame);
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY
{
    return CGRectGetMidY(self.frame);
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

#pragma mark - Orgin/Size
- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

#pragma mark - Width/Height
- (CGFloat)width
{
    return CGRectGetWidth(self.frame);
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return CGRectGetHeight(self.frame);
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

#pragma mark - Intrinsic Content Width/Height
- (CGFloat)intrinsicContentWidth
{
    return self.intrinsicContentSize.width;
}

- (CGFloat)intrinsicContentHeight
{
    return self.intrinsicContentSize.height;
}

#pragma mark - Super and sub view
- (id)superTableView
{
    if ([self.superview isKindOfClass:[UITableView class]]) {
        return self.superview;
    } else {
        return [self.superview superTableView];
    }
}

- (id)superCollectionView
{
    if ([self.superview isKindOfClass:[UICollectionView class]]) {
        return self.superview;
    } else {
        return [self.superview superCollectionView];
    }
}

- (id)superTableViewCell
{
    if ([self.superview isKindOfClass:[UITableViewCell class]]) {
        return self.superview;
    } else {
        return [self.superview superTableViewCell];
    }
}

- (id)superCollectionViewCell
{
    if ([self.superview isKindOfClass:[UICollectionViewCell class]]) {
        return self.superview;
    } else {
        return [self.superview superCollectionViewCell];
    }
}

- (id)subTableView
{
    id resultView = nil;
    for (id subview in self.subviews) {
        if ([subview isKindOfClass:[UITableView class]]) {
            resultView = subview;
        } else {
            resultView = [subview subTableView];
        }
    }
    return resultView;
}

- (id)subCollectionView
{
    id resultView = nil;
    for (id subview in self.subviews) {
        if ([subview isKindOfClass:[UICollectionView class]]) {
            resultView = subview;
        } else if ([subview subviews].count > 0) {
            resultView = [subview subCollectionView];
        }
    }
    return resultView;
}

#pragma mark - Corner radius
- (void)setCornerRadius:(CGFloat)radius
{
    [self setCornerRadius:radius byRoundingCorners:UIRectCornerAllCorners];
}

- (void)setCornerRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor *)color
{
    [self setCornerRadius:radius byRoundingCorners:UIRectCornerAllCorners borderWidth:width borderColor:color];
}

- (void)setCornerRadius:(CGFloat)radius byRoundingCorners:(UIRectCorner)corners
{
    [self setCornerRadius:radius byRoundingCorners:corners borderWidth:0.0 borderColor:nil];
}

- (void)setCornerRadius:(CGFloat)radius byRoundingCorners:(UIRectCorner)corners borderWidth:(CGFloat)width borderColor:(UIColor *)color
{
    CGSize cornerRadii = CGSizeMake(radius, radius);
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:cornerRadii];
    [roundedPath closePath];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = roundedPath.CGPath;
    maskLayer.borderWidth = width;
    maskLayer.lineJoin = kCALineJoinRound;
    maskLayer.borderColor = color.CGColor;
    self.layer.mask = maskLayer;
}

#pragma mark - Gesture
- (void)addSingleTapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:tap];
}

- (void)removeSingleTapGesture
{
    [self removeGestureRecognizer:self.gestureRecognizers.firstObject];
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer
{
    [self endEditing:YES];
}

#pragma mark - Background view
- (void)addBlurBackground
{
    [self removeBlurBackground];
    
    [self addSubview:({
        UIVisualEffectView *background = [[UIVisualEffectView alloc] initWithFrame:self.bounds];
        background.tag = kBackgroundViewTag;
        background.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [background setAnimatedHidden:NO completion:nil];
        background;
    })];
}

- (void)removeBlurBackground
{
    [[self viewWithTag:kBackgroundViewTag] removeFromSuperview];
}

- (void)addDimBackground
{
    [self addBackgroundWithColor:[UIColor colorWithWhite:0 alpha:0.4]];
}

- (void)addBackgroundWithColor:(UIColor *)backgroundColor
{
    [self removeDimBackground];
    
    [self addSubview:({
        UIView *background = [[UIView alloc] initWithFrame:self.bounds];
        background.tag = kBackgroundViewTag;
        background.backgroundColor = backgroundColor;
        background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [background setAnimatedHidden:NO completion:nil];
        background;
    })];
}

- (void)removeDimBackground
{
    [[self viewWithTag:kBackgroundViewTag] removeFromSuperview];
}

- (void)addDarkDimBackground
{
    [self addBackgroundWithColor:[UIColor colorWithWhite:0 alpha:0.8]];
}

- (void)removeDarkDimBackground
{
    [self removeDimBackground];
}

#pragma mark - Animation
+ (void)animateWithDefaultDuration:(KLVoidBlockType)animations
{
    [UIView animateWithDefaultDuration:animations completion:nil];
}

+ (void)animateWithDefaultDuration:(KLVoidBlockType)animations completion:(KLBOOLBlockType)completion
{
    [UIView animateWithDuration:[CATransaction animationDuration] animations:animations completion:completion];
}

+ (void)animateSpringWithDefaultDuration:(KLVoidBlockType)animations
{
    [UIView animateSpringWithDefaultDuration:animations completion:nil];
}

+ (void)animateSpringWithDefaultDuration:(KLVoidBlockType)animations completion:(KLBOOLBlockType)completion
{
    [UIView animateWithDuration:[CATransaction animationDuration]
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:10
                        options:0
                     animations:animations
                     completion:completion];
}

- (void)animateSpringScale
{
    [UIView animateWithDefaultDuration:^{
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateSpringWithDefaultDuration:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)setAnimatedHidden:(BOOL)hidden completion:(KLVoidBlockType)completion
{
    if (!hidden) {
        self.hidden = hidden;
        self.alpha = 0.0;
    }
    
    [UIView animateWithDefaultDuration:^{
        self.alpha = hidden ? 0.0 : 1.0;
    } completion:^(BOOL finished) {
        self.hidden = hidden;
        if (completion) completion();
    }];
}

@end
