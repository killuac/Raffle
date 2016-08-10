//
//  UIImageView+Base.m
//  LuckyDraw
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "UIImageView+Base.h"

@implementation UIImageView (Base)

#pragma mark - Image process
- (void)setCornerRadius:(CGFloat)radius byRoundingCorners:(UIRectCorner)corners borderWidth:(CGFloat)width borderColor:(UIColor *)color
{
    UIImage *image = self.image;
    image = (image.width == image.height) ? image : [image resizableCroppedImage];
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    CGSize cornerRadii = CGSizeMake(radius, radius);
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:cornerRadii];
    [roundedPath addClip];
    roundedPath.lineWidth = width;
    roundedPath.lineJoinStyle = kCGLineJoinRound;
    if (color) {
        [color setStroke];
        [roundedPath stroke];
    }
    [roundedPath closePath];
    
    [image drawInRect:self.bounds];
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end
