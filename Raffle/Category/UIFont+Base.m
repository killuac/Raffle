//
//  UIFont+Base.m
//  Raffle
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import "UIFont+Base.h"

@implementation UIFont (Base)

// Small font
+ (UIFont *)smallFont
{
    return [UIFont systemFontOfSize:12.0f];
}

+ (UIFont *)boldSmallFont
{
    return [UIFont boldSystemFontOfSize:12.0f];
}

// Medium font
+ (UIFont *)mediumFont
{
    return [UIFont systemFontOfSize:14.0f];
}

+ (UIFont *)boldMediumFont
{
    return [UIFont boldSystemFontOfSize:14.0f];
}

// Large font
+ (UIFont *)largeFont
{
    return [UIFont systemFontOfSize:17.0f];
}

+ (UIFont *)boldLargeFont
{
    return [UIFont boldSystemFontOfSize:17.0f];
}

// Extra large font
+ (UIFont *)extraLargeFont
{
    return [UIFont systemFontOfSize:20.0f];
}

+ (UIFont *)boldExtraLargeFont
{
    return [UIFont boldSystemFontOfSize:20.0f];
}

@end
