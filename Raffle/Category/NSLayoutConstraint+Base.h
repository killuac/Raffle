//
//  NSLayoutConstraint+Base.h
//  LuckyDraw
//
//  Created by Killua Liu on 6/26/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (Base)

+ (NSArray<__kindof NSLayoutConstraint *> *)constraintsWithVisualFormat:(NSString *)format views:(NSDictionary<NSString *, id> *)views;

+ (instancetype)constraintWidthWithItem:(UIView *)view constant:(CGFloat)constant;
+ (instancetype)constraintHeightWithItem:(UIView *)view constant:(CGFloat)constant;

+ (instancetype)constraintCenterXWithItem:(UIView *)view;   // refer to super view
+ (instancetype)constraintCenterYWithItem:(UIView *)view;
+ (instancetype)constraintCenterXWithItem:(UIView *)view1 toItem:(UIView *)view2;
+ (instancetype)constraintCenterYWithItem:(UIView *)view1 toItem:(UIView *)view2;

+ (instancetype)constraintTopWithItem:(UIView *)view;
+ (instancetype)constraintBottomWithItem:(UIView *)view;
+ (instancetype)constraintLeadingWithItem:(UIView *)view;
+ (instancetype)constraintTrailingWithItem:(UIView *)view;

@end
