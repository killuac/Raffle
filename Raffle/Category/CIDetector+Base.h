//
//  CIDetector+Base.h
//  Raffle
//
//  Created by Killua Liu on 12/21/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <CoreImage/CoreImage.h>

typedef NS_ENUM(NSUInteger, KLDetectorAccuracy) {
    KLDetectorAccuracyLow,
    KLDetectorAccuracyHigh
};

@interface CIDetector (Base)

+ (CIDetector *)faceDetectorWithAccuracy:(KLDetectorAccuracy)accuracy;
- (NSArray<CIFeature *> *)featuresInUIImage:(UIImage *)image;

@end
