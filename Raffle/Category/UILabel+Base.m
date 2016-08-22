//
//  UILabel+Base.m
//  Raffle
//
//  Created by Killua Liu on 1/27/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "UILabel+Base.h"

NSTimeInterval const KLLabelScrollDelay = 1.0;

@interface UILabel (Private)

@property (nonatomic, strong) NSLayoutConstraint *leadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *trailingConstraint;

@end

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

#pragma mark - Auto scroll
- (NSTimeInterval)scrollDuration
{
    CGFloat scrollSpeed = 50.0;
    CGFloat contentWidth = [self.text widthWithFont:self.font];
    return self.isScrollable ? (contentWidth / scrollSpeed) : 0;
}

- (BOOL)isScrollable
{
    return ([self.text widthWithFont:self.font] > self.superview.width);
}

- (void)didMoveToWindow
{
    if (self.window) {
        [self addContraints];
    }
}

- (void)scrollIfNeeded
{
    if (!self.isScrollable || !self.superview) {
        [self.class cancelPreviousPerformRequestsWithTarget:self];
        self.leadingConstraint.active = NO; return;
    } else {
        self.leadingConstraint.active = YES;
    }
    
    [self.layer removeAllAnimations];
    [self performSelector:@selector(startScroll) withObject:nil afterDelay:KLLabelScrollDelay];
}

- (void)startScroll
{
    [UIView animateWithDuration:self.scrollDuration delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
        self.leadingConstraint.active = NO;
        self.trailingConstraint.active = YES;
        [self.superview layoutIfNeeded];
    } completion:nil];
}

#pragma mark - Constraints
- (void)addContraints
{
    self.leadingConstraint = [NSLayoutConstraint constraintLeadingWithItem:self];
    self.trailingConstraint = [NSLayoutConstraint constraintTrailingWithItem:self];
}

- (void)setLeadingConstraint:(NSLayoutConstraint *)leadingConstraint
{
    objc_setAssociatedObject(self, @selector(leadingConstraint), leadingConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutConstraint *)leadingConstraint
{
    return objc_getAssociatedObject(self, @selector(leadingConstraint));
}

- (void)setTrailingConstraint:(NSLayoutConstraint *)trailingConstraint
{
    objc_setAssociatedObject(self, @selector(trailingConstraint), trailingConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSLayoutConstraint *)trailingConstraint
{
    return objc_getAssociatedObject(self, @selector(trailingConstraint));
}

@end
