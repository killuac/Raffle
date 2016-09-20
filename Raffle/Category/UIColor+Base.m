//
//  UIColor+Base.m
//  Raffle
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
    return [UIColor whiteColor];
}

+ (instancetype)barTintColor
{
    return [UIColor darkBackgroundColor];
}

#pragma mark - Background color
+ (instancetype)backgroundColor
{
//    return KLColorWithRGB(240, 240, 240);
    return KLColorWithRGB(49, 49, 49);
}

+ (instancetype)darkBackgroundColor
{
    return KLColorWithRGB(44, 48, 54);
}

#pragma mark - Text color
+ (instancetype)titleColor
{
    return KLColorWithRGB(49, 49, 49);
}

+ (instancetype)buttonTitleColor
{
    return [UIColor whiteColor];
}

+ (instancetype)subtitleColor
{
    return KLColorWithRGB(145, 152, 159);
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
    return KLColorWithHexString(@"3399FF");
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
