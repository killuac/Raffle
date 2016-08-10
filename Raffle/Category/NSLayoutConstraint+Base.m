//
//  NSLayoutConstraint+Base.m
//  LuckyDraw
//
//  Created by Killua Liu on 6/26/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "NSLayoutConstraint+Base.h"

@implementation NSLayoutConstraint (Base)

+ (NSArray<__kindof NSLayoutConstraint *> *)constraintsWithVisualFormat:(NSString *)format views:(NSDictionary<NSString *, id> *)views
{
    return [self constraintsWithVisualFormat:format options:0 metrics:nil views:views];
}

+ (instancetype)constraintWidthWithItem:(UIView *)view constant:(CGFloat)constant
{
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                           toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:constant];
}

+ (instancetype)constraintHeightWithItem:(UIView *)view constant:(CGFloat)constant
{
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                           toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:constant];
}

+ (instancetype)constraintCenterXWithItem:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                           toItem:view.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
}

+ (instancetype)constraintCenterYWithItem:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                           toItem:view.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
}

+ (instancetype)constraintCenterXWithItem:(UIView *)view1 toItem:(UIView *)view2
{
    return [NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                           toItem:view2 attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
}

+ (instancetype)constraintCenterYWithItem:(UIView *)view1 toItem:(UIView *)view2
{
    return [NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                           toItem:view2 attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
}

+ (instancetype)constraintTopWithItem:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                           toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1 constant:0];
}

+ (instancetype)constraintBottomWithItem:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                           toItem:view.superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
}

+ (instancetype)constraintLeadingWithItem:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                           toItem:view.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
}

+ (instancetype)constraintTrailingWithItem:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                           toItem:view.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
}

@end
