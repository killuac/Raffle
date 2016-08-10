//
//  UILabel+Base.m
//  LuckyDraw
//
//  Created by Killua Liu on 1/27/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "UILabel+Base.h"

@implementation UILabel (Base)

+ (instancetype)labelWithText:(NSString *)text
{
    UILabel *label = [UILabel newAutoLayoutView];
    label.text = text;
    label.font = [UIFont subtitleFont];
    label.textColor = [UIColor subtitleColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    
    return label;
}

+ (instancetype)labelWithText:(NSString *)text attributes:(NSDictionary<NSString *, id> *)attributes
{
    UILabel *label = [UILabel labelWithText:text];
    label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    return label;
}

- (CGFloat)fontHeight
{
    return [self.text heightWithFont:self.font];
}

@end
