//
//  UIColor+Base.h
//  Raffle
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_INLINE UIColor *KLColorWithRGB(CGFloat r, CGFloat g, CGFloat b) { return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]; }
NS_INLINE UIColor *KLColorWithRGBA(CGFloat r, CGFloat g, CGFloat b, CGFloat a) { return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0]; }
NS_INLINE UIColor *KLColorWithHexString(NSString *hexString) {
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hexInt; [scanner scanHexInt: &hexInt];
    return KLColorWithRGB((hexInt & 0xFF0000) >> 16, (hexInt & 0xFF00) >> 8, (hexInt & 0xFF));
}

@interface UIColor (Base)

@property (class, nonatomic, readonly) UIColor *tintColor;
@property (class, nonatomic, readonly) UIColor *barTintColor;

@property (class, nonatomic, readonly) UIColor *backgroundColor;
@property (class, nonatomic, readonly) UIColor *darkBackgroundColor;

@property (class, nonatomic, readonly) UIColor *titleColor;
@property (class, nonatomic, readonly) UIColor *buttonTitleColor;
@property (class, nonatomic, readonly) UIColor *subtitleColor;
@property (class, nonatomic, readonly) UIColor *separatorColor;

@property (class, nonatomic, readonly) UIColor *defaultButtonColor;
@property (class, nonatomic, readonly) UIColor *primaryButtonColor;
@property (class, nonatomic, readonly) UIColor *destructiveButtonColor;
@property (class, nonatomic, readonly) UIColor *disabledButtonColor;
@property (class, nonatomic, readonly) UIColor *linkButtonColor;

- (UIColor *)lighterColor;
- (UIColor *)darkerColor;

- (UIColor *)blendedColorWithFraction:(CGFloat)fraction endColor:(UIColor *)endColor;

@end
