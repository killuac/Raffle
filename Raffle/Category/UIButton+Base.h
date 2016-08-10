//
//  UIButton+Base.h
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright (c) 2015 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KLButonStyle) {
    KLButonStyleNone,
    KLButonStyleDefault,
    KLButonStylePrimary,
    KLButonStyleDestructive
};

typedef NS_ENUM(NSUInteger, KLButtonLayout) {
    KLButtonLayoutHorizontalNone,
    KLButtonLayoutHorizontalImageLeft,      // Default for image and title
    KLButtonLayoutHorizontalImageRight,
    KLButtonLayoutVerticalImageUp,
    KLButtonLayoutVerticalImageDown
};

@interface UIButton (Base)

+ (instancetype)buttonWithTitle:(NSString *)title;
+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName;
+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName layout:(KLButtonLayout)layout;
+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName disabledImageName:(NSString *)disabledImageName;
+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName disabledImageName:(NSString *)disabledImageName layout:(KLButtonLayout)layout;
+ (instancetype)buttonWithImageName:(NSString *)imageName;
+ (instancetype)buttonWithImageName:(NSString *)imageName selectedImageName:(NSString *)selImageName;
+ (instancetype)buttonWithImageName:(NSString *)imageName disabledImageName:(NSString *)disabledImageName;

+ (instancetype)systemButtonWithTitle:(NSString *)title;
+ (instancetype)linkButtonWithTitle:(NSString *)title;

+ (instancetype)defaultButtonWithTitle:(NSString *)title;
+ (instancetype)primaryButtonWithTitle:(NSString *)title;
+ (instancetype)destructiveButtonWithTitle:(NSString *)title;

- (void)setLayout:(KLButtonLayout)layout;
- (void)setNormalTitle:(NSString *)title;
- (void)addTarget:(id)target action:(SEL)action;

@end
