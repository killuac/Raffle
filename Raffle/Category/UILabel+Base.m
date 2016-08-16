//
//  UILabel+Base.m
//  Raffle
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

#pragma mark - Auto scroll
- (void)setIsAutoScroll:(BOOL)isAutoScroll
{
    objc_setAssociatedObject(self, @selector(isAutoScroll), @(isAutoScroll), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAutoScroll
{
    return [objc_getAssociatedObject(self, @selector(isAutoScroll)) boolValue];
}

- (NSTimeInterval)scrollDuration
{
    return 0;
}

- (void)didMoveToWindow
{
    if (self.isAutoScroll && self.window) {
        [self scrollLabelIfNeeded];
    }
}

- (void)scrollLabelIfNeeded
{
    
}

@end
