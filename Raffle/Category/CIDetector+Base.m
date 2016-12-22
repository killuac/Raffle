//
//  CIDetector+Base.m
//  Raffle
//
//  Created by Killua Liu on 12/21/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "CIDetector+Base.h"

@implementation CIDetector (Base)

+ (CIContext *)sharedContext
{
    static id sharedContext = nil;
    KLDispatchOnce(^{
        sharedContext = [CIContext contextWithOptions:nil];
    });
    return sharedContext;
}

+ (CIDetector *)faceDetectorWithAccuracy:(KLDetectorAccuracy)accuracy
{
    NSMutableDictionary *options = [NSMutableDictionary new];
    if (accuracy == KLDetectorAccuracyLow) {
        options[CIDetectorAccuracy] = CIDetectorAccuracyLow;
    } else {
        options[CIDetectorAccuracy] = CIDetectorAccuracyHigh;
    }
    options[CIDetectorMinFeatureSize] = @(0.01);
    
    return [self detectorOfType:CIDetectorTypeFace context:self.sharedContext options:options];
}

- (NSArray<CIFeature *> *)featuresInUIImage:(UIImage *)image
{
    NSMutableDictionary *options = [NSMutableDictionary new];
    options[CIDetectorImageOrientation] = @(image.exifImageOrientation);
    
    return [self featuresInImage:[CIImage imageWithCGImage:image.CGImage] options:options];
}

@end
