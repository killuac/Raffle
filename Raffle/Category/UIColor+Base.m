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

- (UIColor *)blendedColorWithFraction:(CGFloat)fraction endColor:(UIColor *)endColor
{
    if (fraction <= 0.0f) return self;
    if (fraction >= 1.0f) return endColor;
    
    CGFloat a1, b1, c1, d1 = 0.0f;
    CGFloat a2, b2, c2, d2 = 0.0f;
    
    #define INTERPOLATE(x) KLColorInterpolate(x ## 1, x ## 2, fraction)
    
    // White
    if ([self getWhite:&a1 alpha:&b1] && [endColor getWhite:&a2 alpha:&b2]){
        return [UIColor colorWithWhite:INTERPOLATE(a) alpha:INTERPOLATE(b)];
    }
    
    // RGB
    if ([self getRed:&a1 green:&b1 blue:&c1 alpha:&d1] && [endColor getRed:&a2 green:&b2 blue:&c2 alpha:&d2]){
        return [UIColor colorWithRed:INTERPOLATE(a) green:INTERPOLATE(b) blue:INTERPOLATE(c) alpha:INTERPOLATE(d)];
    }
    
    // HSB
    if ([self getHue:&a1 saturation:&b1 brightness:&c1 alpha:&d1] && [endColor getHue:&a2 saturation:&b2 brightness:&c2 alpha:&d2]){
        return [UIColor colorWithHue:INTERPOLATE(a) saturation:INTERPOLATE(b) brightness:INTERPOLATE(c) alpha:INTERPOLATE(d)];
    }
    
    return UIColor.tintColor;
}

NS_INLINE CGFloat KLColorInterpolate(CGFloat a, CGFloat b, CGFloat fraction) {
    return (a + ((b - a) * fraction));
}

#pragma mark - Tint color
+ (UIColor *)tintColor
{
    return UIColor.whiteColor;
}

+ (UIColor *)barTintColor
{
    return KLColorWithRGB(55, 58, 63);
}

#pragma mark - Background color
+ (UIColor *)backgroundColor
{
    return KLColorWithRGB(250, 250, 250);
}

+ (UIColor *)darkBackgroundColor
{
    return KLColorWithRGB(40, 44, 50);
}

+ (UIColor *)dimmingBackgroundColor
{
    return [UIColor colorWithWhite:0 alpha:0.4];
}

#pragma mark - Text color
+ (UIColor *)titleColor
{
    return KLColorWithRGB(49, 49, 49);
}

+ (UIColor *)buttonTitleColor
{
    return UIColor.whiteColor;
}

+ (UIColor *)subtitleColor
{
    return KLColorWithRGB(145, 152, 159);
}

+ (UIColor *)separatorColor
{
    return KLColorWithRGB(204, 204, 204);
}

#pragma mark - Button color
+ (UIColor *)defaultButtonColor
{
    return UIColor.whiteColor;
}

+ (UIColor *)primaryButtonColor
{
    return KLColorWithHexString(@"3399FF");
}

+ (UIColor *)destructiveButtonColor
{
    return UIColor.redColor;
}

+ (UIColor *)disabledButtonColor
{
    return KLColorWithRGB(219, 219, 219);
}

+ (UIColor *)linkButtonColor
{
    return [UIColor.blueColor colorWithAlphaComponent:0.6];
}

@end
