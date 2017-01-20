//
//  UIImage+Base.h
//  Raffle
//
//  Created by Killua Liu on 12/31/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

@import UIKit;
@import ImageIO;

UIKIT_EXTERN BOOL KLImageOrientationIsPortrait(UIImageOrientation imageOrientation);
UIKIT_EXTERN CGImagePropertyOrientation KLEXIFImageOrientationFromImageOrientation(UIImageOrientation imageOrientation);


@interface UIImage (Base)

@property (nonatomic, assign, getter=isSelected) BOOL selected;

@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) CGImagePropertyOrientation exifImageOrientation;

- (UIImage *)originalImage;
- (UIImage *)orientationImage;
- (UIImage *)resizableCroppedImage;             // Resize and crop in center
- (UIImage *)brightenWithAlpha:(CGFloat)alpha;  // Value range (0, 1)
- (UIImage *)antialiasingImage;                 // layer.allowsEdgeAntialiasing = YES

@end
