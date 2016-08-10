//
//  UILabel+Base.h
//  LuckyDraw
//
//  Created by Killua Liu on 1/27/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Base)

+ (instancetype)labelWithText:(NSString *)text;
+ (instancetype)labelWithText:(NSString *)text attributes:(NSDictionary<NSString *, id> *)attributes;

@property (nonatomic, assign, readonly) CGFloat fontHeight;

@end
