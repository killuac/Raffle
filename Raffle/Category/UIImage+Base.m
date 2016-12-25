//
//  UIImage+Base.m
//  Raffle
//
//  Created by Killua Liu on 12/31/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import "UIImage+Base.h"

BOOL KLImageOrientationIsPortrait(UIImageOrientation imageOrientation)
{
    return (imageOrientation == UIImageOrientationUp || imageOrientation == UIImageOrientationDown ||
            imageOrientation == UIImageOrientationUpMirrored || imageOrientation == UIImageOrientationDownMirrored);
}

CGImagePropertyOrientation KLEXIFImageOrientationFromImageOrientation(UIImageOrientation imageOrientation)
{
    CGImagePropertyOrientation propertyOrientation;
    switch (imageOrientation) {
        case UIImageOrientationUp:
            propertyOrientation = kCGImagePropertyOrientationUp;
            break;
        case UIImageOrientationDown:
            propertyOrientation = kCGImagePropertyOrientationDown;
            break;
        case UIImageOrientationLeft:
            propertyOrientation = kCGImagePropertyOrientationLeft;
            break;
        case UIImageOrientationRight:
            propertyOrientation = kCGImagePropertyOrientationRight;
            break;
        case UIImageOrientationUpMirrored:
            propertyOrientation = kCGImagePropertyOrientationUpMirrored;
            break;
        case UIImageOrientationDownMirrored:
            propertyOrientation = kCGImagePropertyOrientationDownMirrored;
            break;
        case UIImageOrientationLeftMirrored:
            propertyOrientation = kCGImagePropertyOrientationLeftMirrored;
            break;
        case UIImageOrientationRightMirrored:
            propertyOrientation = kCGImagePropertyOrientationRightMirrored;
            break;
    }
    return propertyOrientation;
}


@implementation UIImage (Base)

- (BOOL)isSelected
{
    return [objc_getAssociatedObject(self, @selector(isSelected)) boolValue];
}

- (void)setSelected:(BOOL)selected
{
    objc_setAssociatedObject(self, @selector(isSelected), @(selected), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)width
{
    return self.size.width;
}

- (CGFloat)height
{
    return self.size.height;
}

- (CGImagePropertyOrientation)exifImageOrientation
{
    return KLEXIFImageOrientationFromImageOrientation(self.imageOrientation);
}

#pragma mark - Generate new image
- (UIImage *)originalImage
{
    return [self imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIImage *)orientationImage
{
    CGAffineTransform transform;
    switch (self.imageOrientation) {
        case UIImageOrientationUp:
            return self;
            break;
            
        case UIImageOrientationDown:
            transform = CGAffineTransformTranslate(transform, self.width, self.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
            transform = CGAffineTransformTranslate(transform, self.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
            transform = CGAffineTransformTranslate(transform, 0, self.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL, self.width, self.height,
                                                 CGImageGetBitsPerComponent(self.CGImage),
                                                 CGImageGetBytesPerRow(self.CGImage),
                                                 CGImageGetColorSpace(self.CGImage),
                                                 CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(context, transform);
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(context, CGRectMake(0, 0, self.height, self.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(context, CGRectMake(0, 0, self.width, self.height), self.CGImage);
            break;
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGContextRelease(context);
    CGImageRelease(imageRef);
    
    return image;
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

- (UIImage *)antialiasingImage
{
    CGRect rect = CGRectMake(0, 0, self.width, self.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    [self drawInRect:CGRectInset(rect, 1, 1)];
    UIImage *antiImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return antiImage;
}

@end
