//
//  NSUserDefaults+Base.m
//  Raffle
//
//  Created by Killua Liu on 12/22/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "NSUserDefaults+Base.h"

@implementation NSUserDefaults (Base)

+ (BOOL)isEmpty
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NSStringFromSelector(@selector(flashMode))] == nil;
}

+ (NSInteger)flashMode
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:NSStringFromSelector(@selector(flashMode))];
}

+ (void)setFlashMode:(NSInteger)flashMode
{
    [[NSUserDefaults standardUserDefaults] setInteger:flashMode forKey:NSStringFromSelector(@selector(flashMode))];
}

+ (BOOL)isFaceDetectionOn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:NSStringFromSelector(@selector(isFaceDetectionOn))];
}

+ (void)setFaceDetectionOn:(BOOL)faceDetectionOn
{
    [[NSUserDefaults standardUserDefaults] setBool:faceDetectionOn forKey:NSStringFromSelector(@selector(isFaceDetectionOn))];
}

@end
