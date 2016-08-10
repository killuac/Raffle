//
//  UIImage+Base.m
//  Raffle
//
//  Created by Killua Liu on 12/31/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import "UIImage+Base.h"

@implementation UIImage (Base)

- (CGFloat)width
{
    return self.size.width;
}

- (CGFloat)height
{
    return self.size.height;
}

- (UIImage *)originalImage
{
    return [self imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIImage *)resizableCroppedImage
{
    CGFloat ratio;
    CGFloat width = self.width, height = self.height;
    CGRect cropRect = CGRectZero;
    
    if (width >= height) {
        ratio = height / width;
        cropRect = CGRectMake((width - height) / 2, 0, width * ratio, height);
    } else {
        ratio = width / height;
        cropRect = CGRectMake(0, (height - width) / 2, width, height * ratio);
    }
    
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef];
    CGImageRelease(croppedImageRef);
    return croppedImage;
}

- (UIImage *)brightenWithAlpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContext(self.size);
    CGRect imageRect = CGRectMake(0, 0, self.width, self.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawInRect:imageRect];
    
    // Brightness overlay
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:alpha].CGColor);
    CGContextAddRect(context, imageRect);
    CGContextFillPath(context);
    
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

@end
