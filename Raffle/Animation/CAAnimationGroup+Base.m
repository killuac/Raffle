//
//  CAAnimationGroup+Base.m
//  Raffle
//
//  Created by Killua Liu on 8/28/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "CAAnimationGroup+Base.h"

@implementation CAAnimationGroup (Base)

+ (instancetype)animationWithDuration:(NSTimeInterval)duration animations:(NSArray<CAAnimation *> *)animations
{
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = duration;
    animationGroup.animations = animations;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    return animationGroup;
}

@end
