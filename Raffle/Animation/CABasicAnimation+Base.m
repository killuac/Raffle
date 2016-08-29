//
//  CABasicAnimation+Base.m
//  Raffle
//
//  Created by Killua Liu on 8/29/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "CABasicAnimation+Base.h"

@implementation CABasicAnimation (Base)

+ (instancetype)animationWithDuration:(NSTimeInterval)duration keyPath:(NSString *)keyPath
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.duration = duration;
    return animation;
}

@end
