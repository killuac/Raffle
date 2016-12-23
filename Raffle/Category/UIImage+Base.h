//
//  UIImage+Base.h
//  Raffle
//
//  Created by Killua Liu on 12/31/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

@import UIKit;
@import ImageIO;

typedef NS_ENUM(NSInteger, KLGenderType) {
    KLGenderTypeUnknown = 0,
    KLGenderTypeFemale = -1,
    KLGenderTypeMale = 1
};

NS_INLINE UIImage *KLImageEmpty() { return [UIImage imageNamed:@"image_empty.png"]; }
NS_INLINE UIImage *KLImagePlaceholder() { return [UIImage imageNamed:@"image_default.png"]; }
NS_INLINE UIImage *KLImageLoadFailed() { return [UIImage imageNamed:@"image_load_failed.png"]; }
NS_INLINE UIImage *KLImageOfficialAvatar() { return [UIImage imageNamed:@"image_official_avatar.png"]; }

NS_INLINE UIImage *KLImageIconByGender(KLGenderType gender) {
    if (gender == 0) return nil;
    return (gender > 0) ? [UIImage imageNamed:@"icon_male.png"] : [UIImage imageNamed:@"icon_female.png"];
}

NS_INLINE UIImage *KLImageAvatarByGender(KLGenderType gender) {
    if (gender == 0) return [UIImage imageNamed:@"image_default_avatar.png"];
    return (gender > 0) ? [UIImage imageNamed:@"image_male_avatar.png"] : [UIImage imageNamed:@"image_male_avatar.png"];
}

UIKIT_EXTERN CGImagePropertyOrientation KLEXIFImageOrientationFromImageOrientation(UIImageOrientation imageOrientation);


@interface UIImage (Base)

@property (nonatomic, assign, getter=isSelected) BOOL selected;

@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) CGImagePropertyOrientation exifImageOrientation;

- (UIImage *)originalImage;
- (UIImage *)rotatedImage;
- (UIImage *)resizableCroppedImage;             // Resize and crop in center
- (UIImage *)brightenWithAlpha:(CGFloat)alpha;  // Value range (0, 1)
- (UIImage *)antialiasingImage;                 // layer.allowsEdgeAntialiasing = YES

@end
