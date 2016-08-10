//
//  UIFont+Base.h
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Base)

+ (instancetype)defaultFont;
+ (instancetype)bigFont;
+ (instancetype)boldBigFont;
+ (instancetype)titleFont;
+ (instancetype)boldTitleFont;
+ (instancetype)subtitleFont;
+ (instancetype)descriptionFont;

@end
