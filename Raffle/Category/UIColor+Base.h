//
//  UIColor+Base.h
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Base)

+ (instancetype)tintColor;
+ (instancetype)barTintColor;

+ (instancetype)backgroundColor;
+ (instancetype)darkBackgroundColor;

+ (instancetype)titleColor;
+ (instancetype)subtitleColor;
+ (instancetype)separatorColor;

+ (instancetype)defaultButtonColor;
+ (instancetype)primaryButtonColor;
+ (instancetype)destructiveButtonColor;
+ (instancetype)disabledButtonColor;
+ (instancetype)linkButtonColor;

- (UIColor *)lighterColor;
- (UIColor *)darkerColor;

@end
