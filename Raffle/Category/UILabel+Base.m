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
    CGFloat scrollSpeed = 80.0;
    CGFloat contentWidth = [self.text widthWithFont:self.font];
    return self.isScrollable ? (contentWidth / scrollSpeed) : 0;
}

- (BOOL)isScrollable
{
    return (self.superview && [self.text widthWithFont:self.font] > self.superview.width);
}

- (void)didMoveToWindow
{
    if (self.window) {
        [self addContraints];
    }
}

- (void)scrollIfNeeded
{
    [self prepareForScroll];
    
    if (!self.isScrollable) {
        self.leadingConstraint.active = NO; return;
    } else {
        self.leadingConstraint.active = YES;
    }
    
    [self performSelector:@selector(startScroll) withObject:nil afterDelay:0];  // Start delay 1 frame(1/60)
}

- (void)startScroll
{
    KLDispatchMainAfter(KLLabelScrollDelay, ^{
        self.gradientMaskLayer.locations = self.scrollingGradientLocations;
    });
    
    [UIView animateWithDuration:self.scrollDuration delay:KLLabelScrollDelay options:UIViewAnimationOptionCurveLinear animations:^{
        self.leadingConstraint.active = NO;
        self.trailingConstraint.active = YES;
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.gradientMaskLayer.locations = self.endGradientLocations;
        if(finished) [self reverseScroll];
    }];
}

- (void)reverseScroll
{
    KLDispatchMainAfter(KLLabelScrollDelay, ^{
        self.gradientMaskLayer.locations = self.scrollingGradientLocations;
    });
    
    [UIView animateWithDuration:self.scrollDuration delay:KLLabelScrollDelay options:UIViewAnimationOptionCurveLinear animations:^{
        self.leadingConstraint.active = YES;
        self.trailingConstraint.active = NO;
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.gradientMaskLayer.locations = self.startGradientLocations;
        if(finished) [self startScroll];
    }];
}

- (void)prepareForScroll
{
    [self.layer removeAllAnimations];
    if (self.isScrollable) {
        [self addGradientMaskLayerToSuperView];
    } else {
        self.superview.layer.mask = nil;
    }
}

#pragma mark - Gradient
- (void)addGradientMaskLayerToSuperView
{
    [self.superview layoutIfNeeded];
    
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.bounds = self.superview.bounds;
    gradientMask.position = CGPointMake(CGRectGetMidX(self.superview.bounds), CGRectGetMidY(self.superview.bounds));
    gradientMask.shouldRasterize = YES;
    gradientMask.rasterizationScale = [UIScreen mainScreen].scale;
    gradientMask.startPoint = CGPointMake(0, 0.5);
    gradientMask.endPoint = CGPointMake(1, 0.5);
    
    // Setup fade mask colors and location
    id transparent = (id)[UIColor clearColor].CGColor;
    id opaque = (id)[UIColor blackColor].CGColor;
    gradientMask.colors = @[transparent, opaque, opaque, transparent];
    gradientMask.locations = self.startGradientLocations;
    
    self.superview.layer.mask = gradientMask;
}

- (CAGradientLayer *)gradientMaskLayer
{
    return (id)self.superview.layer.mask;
}

- (CGFloat)fadeStop
{
    return (10 / self.width);
}

- (NSArray *)startGradientLocations
{
    return @[@0, @0, @(1 - self.fadeStop), @1];
}

- (NSArray *)scrollingGradientLocations
{
    return @[@0, @(self.fadeStop), @(1 - self.fadeStop), @1];
}

- (NSArray *)endGradientLocations
{
    return @[@0, @(self.fadeStop), @1, @1];
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
