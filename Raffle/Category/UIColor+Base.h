//
//  UIColor+Base.h
//  Raffle
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_INLINE UIColor *KLColorWithRGB(CGFloat r, CGFloat g, CGFloat b) { return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]; }
NS_INLINE UIColor *KLColorWithRGBA(CGFloat r, CGFloat g, CGFloat b, CGFloat a) { return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]; }
NS_INLINE UIColor *KLColorWithHexString(NSString *hexString) {
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hexInt; [scanner scanHexInt: &hexInt];
    return KLColorWithRGB((hexInt & 0xFF0000) >> 16, (hexInt & 0xFF00) >> 8, (hexInt & 0xFF));
}

@interface UIColor (Base)

+ (instancetype)tintColor;
+ (instancetype)barTintColor;

+ (instancetype)backgroundColor;
+ (instancetype)darkBackgroundColor;

+ (instancetype)titleColor;
+ (instancetype)buttonTitleColor;
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
