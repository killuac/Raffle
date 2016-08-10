//
//  UIFont+Base.m
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import "UIFont+Base.h"

@implementation UIFont (Base)

+ (instancetype)defaultFont
{
    return [UIFont systemFontOfSize:12.0f];
}

+ (instancetype)bigFont
{
    return [UIFont systemFontOfSize:20.0f];
}

+ (instancetype)boldBigFont
{
    return [UIFont boldSystemFontOfSize:20.0f];
}

+ (instancetype)titleFont
{
    return [UIFont systemFontOfSize:17.0f];
}

+ (instancetype)boldTitleFont
{
    return [UIFont boldSystemFontOfSize:17.0f];
}

+ (instancetype)subtitleFont
{
    return [UIFont systemFontOfSize:14.0f];
}

+ (instancetype)descriptionFont
{
    return [UIFont systemFontOfSize:15.0f];
}

@end
