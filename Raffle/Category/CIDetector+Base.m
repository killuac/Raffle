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

+ (CIDetector *)faceDetectorWithAccuracy:(KLDetectorAccuracy)accuracy tracking:(BOOL)tracking
{
    NSMutableDictionary *options = [NSMutableDictionary new];
    if (accuracy == KLDetectorAccuracyLow) {
        options[CIDetectorAccuracy] = CIDetectorAccuracyLow;
    } else {
        options[CIDetectorAccuracy] = CIDetectorAccuracyHigh;
    }
    options[CIDetectorTracking] = @(tracking);
    options[CIDetectorMinFeatureSize] = @(0.01);
    
    return [self detectorOfType:CIDetectorTypeFace context:self.sharedContext options:options];
}

- (NSArray<CIFeature *> *)featuresInCIImage:(CIImage *)image
{
    UIImageOrientation orientation;
    switch (UIDevice.currentDevice.orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = UIImageOrientationLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = UIImageOrientationRight;
            break;
        default:
            orientation = UIImageOrientationUp;
            break;
    }
    NSMutableDictionary *options = [NSMutableDictionary new];
    options[CIDetectorImageOrientation] = @(orientation);
    
    return [self featuresInImage:image options:options];
}

@end
