//
//  UIColor+Base.m
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import "UIColor+Base.h"

@implementation UIColor (Base)

- (UIColor *)lighterColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h saturation:s brightness:MIN(b * 1.3, 1.0) alpha:a];
    return self;
}

- (UIColor *)darkerColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h saturation:s brightness:b * 0.75 alpha:a];
    return self;
}

#pragma mark - Tint color
+ (instancetype)tintColor
{
    return KLColorWithRGB(49, 49, 49);
}

+ (instancetype)barTintColor
{
    return [UIColor whiteColor];
}

#pragma mark - Background color
+ (instancetype)backgroundColor
{
    return KLColorWithRGB(240, 240, 244);  // 冷白
}

+ (instancetype)darkBackgroundColor
{
    return KLColorWithRGB(40, 40, 40);
}

#pragma mark - Text color
+ (instancetype)titleColor
{
    return KLColorWithRGB(55, 60, 56);
}

+ (instancetype)subtitleColor
{
    return KLColorWithRGB(145, 152, 159);  // 银鼠
}

+ (instancetype)separatorColor
{
    return KLColorWithRGB(204, 204, 204);
}

#pragma mark - Button color
+ (instancetype)defaultButtonColor
{
    return [UIColor whiteColor];
}

+ (instancetype)primaryButtonColor
{
    return [UIColor tintColor];
}

+ (instancetype)destructiveButtonColor
{
    return [UIColor redColor];
}

+ (instancetype)disabledButtonColor
{
    return KLColorWithRGB(219, 219, 219);
}

+ (instancetype)linkButtonColor
{
    return [[UIColor blueColor] colorWithAlphaComponent:0.6];
}

@end
