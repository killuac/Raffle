//
//  NSUserDefaults+Base.m
//  Raffle
//
//  Created by Killua Liu on 12/22/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "NSUserDefaults+Base.h"

@implementation NSUserDefaults (Base)

+ (BOOL)hasLaunchedOnce
{
    return [NSUserDefaults.standardUserDefaults boolForKey:NSStringFromSelector(@selector(hasLaunchedOnce))];
}

+ (void)setLaunchedOnce:(BOOL)hasLaunchedOnce
{
    [NSUserDefaults.standardUserDefaults setBool:hasLaunchedOnce forKey:NSStringFromSelector(@selector(hasLaunchedOnce))];
}

+ (BOOL)hasShownShakeTip
{
    return [NSUserDefaults.standardUserDefaults boolForKey:NSStringFromSelector(@selector(hasShownShakeTip))];
}

+ (void)setShownShakeTip:(BOOL)shownShakeTip
{
    [NSUserDefaults.standardUserDefaults setBool:shownShakeTip forKey:NSStringFromSelector(@selector(hasShownShakeTip))];
}

+ (BOOL)hasShownReloadTip
{
    return [NSUserDefaults.standardUserDefaults boolForKey:NSStringFromSelector(@selector(hasShownReloadTip))];
}

+ (void)setShownReloadTip:(BOOL)shownReloadTip
{
    [NSUserDefaults.standardUserDefaults setBool:shownReloadTip forKey:NSStringFromSelector(@selector(hasShownReloadTip))];
}

+ (BOOL)hasShownDeleteTip
{
    return [NSUserDefaults.standardUserDefaults boolForKey:NSStringFromSelector(@selector(hasShownDeleteTip))];
}

+ (void)setShownDeleteTip:(BOOL)shownDeleteTip
{
    [NSUserDefaults.standardUserDefaults setBool:shownDeleteTip forKey:NSStringFromSelector(@selector(hasShownDeleteTip))];
}

+ (BOOL)hasShownFaceDetectionTip
{
    return [NSUserDefaults.standardUserDefaults boolForKey:NSStringFromSelector(@selector(hasShownFaceDetectionTip))];
}

+ (void)setShownFaceDetectionTip:(BOOL)shownFaceDetectionTip
{
    [NSUserDefaults.standardUserDefaults setBool:shownFaceDetectionTip forKey:NSStringFromSelector(@selector(hasShownFaceDetectionTip))];
}

+ (NSInteger)flashMode
{
    return [NSUserDefaults.standardUserDefaults integerForKey:NSStringFromSelector(@selector(flashMode))];
}

+ (void)setFlashMode:(NSInteger)flashMode
{
    [NSUserDefaults.standardUserDefaults setInteger:flashMode forKey:NSStringFromSelector(@selector(flashMode))];
}

+ (BOOL)isFaceDetectionOn
{
    return [NSUserDefaults.standardUserDefaults boolForKey:NSStringFromSelector(@selector(isFaceDetectionOn))];
}

+ (void)setFaceDetectionOn:(BOOL)faceDetectionOn
{
    [NSUserDefaults.standardUserDefaults setBool:faceDetectionOn forKey:NSStringFromSelector(@selector(isFaceDetectionOn))];
}

@end
