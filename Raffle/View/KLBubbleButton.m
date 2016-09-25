//
//  KLBubbleButton.m
//  Raffle
//
//  Created by Killua Liu on 9/22/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLBubbleButton.h"

@implementation KLBubbleButton

- (void)drawRect:(CGRect)rect
{
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self.width / 2;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    UIColor *white = [UIColor whiteColor];
    UIColor *whiteTransparent = [white colorWithAlphaComponent:0];
    UIColor *black = [UIColor blackColor];
    UIColor *gray = [UIColor grayColor];
    UIColor *backgroundColor = self.backgroundColor ? : [UIColor clearColor];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Gradient
    NSArray *outerColors = @[(id)whiteTransparent.CGColor, (id)[whiteTransparent blendedColorWithFraction:0.5 endColor:black].CGColor, (id)black.CGColor];
    CGFloat outerLocations[] = {0, 1, 1};
    CGGradientRef outerGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)outerColors, outerLocations);
    
    NSArray *aboveColors = @[(id)white.CGColor, (id)[white blendedColorWithFraction:0.5 endColor:whiteTransparent].CGColor, (id)whiteTransparent.CGColor, (id)whiteTransparent.CGColor];
    CGFloat aboveLocations[] = {0, 0.21, 0.64, 1};
    CGGradientRef aboveGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)aboveColors, aboveLocations);
    
    NSArray *belowColors = @[(id)whiteTransparent.CGColor, (id)[whiteTransparent blendedColorWithFraction:0.5 endColor:whiteTransparent].CGColor,
                             (id)whiteTransparent.CGColor, (id)[whiteTransparent blendedColorWithFraction:0.5 endColor:gray].CGColor, (id)gray.CGColor];
    CGFloat belowLocations[] = {0, 0.28, 0.28, 1, 1};
    CGGradientRef belowGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)belowColors, belowLocations);
    
    // Backgroud circle
    UIBezierPath *bgCirclePath = [UIBezierPath bezierPathWithOvalInRect:rect];
    [backgroundColor setFill];
    [bgCirclePath fill];
    
    // Outer circle
    UIBezierPath *outerCirclePath = [UIBezierPath bezierPathWithOvalInRect:rect];
    CGContextSaveGState(context);
    [outerCirclePath addClip];
    CGContextDrawRadialGradient(context, outerGradient,
                                CGPointMake(30.0/60*width, 33.66/60*height), 26.14/60*height,
                                CGPointMake(30.0/60*width, 30.0/60*height), 30.0/60*height,
                                kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    
    // Above Oval
    UIBezierPath *aboveOvalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(12.0/60*width, 1.0/60*height, 36.0/60*width, 28.0/60*height)];
    CGContextSaveGState(context);
    [aboveOvalPath addClip];
    CGContextDrawLinearGradient(context, aboveGradient, CGPointMake(30.0/60*width, 1.0/60*height), CGPointMake(30.0/60*width, 29.0/60*height), 0);
    CGContextRestoreGState(context);
    
    // Below Oval
    UIBezierPath *belowOvalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(7.0/60*width, 25.5/60*height, 46.0/60*width, 34.0/60*height)];
    CGContextSaveGState(context);
    [belowOvalPath addClip];
    CGContextDrawLinearGradient(context, belowGradient, CGPointMake(30.0/60*width, 25.5/60*height), CGPointMake(30.0/60*width, 59.5/60*height), 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(outerGradient);
    CGGradientRelease(aboveGradient);
    CGGradientRelease(belowGradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [UIView animateWithDuration:1.0
                          delay:0.0
         usingSpringWithDamping:0.15
          initialSpringVelocity:10
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(0.9, 0.9);
                     } completion:nil];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [UIView animateWithDefaultDuration:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.transform = CGAffineTransformIdentity;
    [super touchesCancelled:touches withEvent:event];
}

@end
