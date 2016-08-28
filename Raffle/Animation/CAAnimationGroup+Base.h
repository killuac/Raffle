//
//  CAAnimationGroup+Base.h
//  Raffle
//
//  Created by Killua Liu on 8/28/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimationGroup (Base)

+ (instancetype)animationWithDuration:(NSTimeInterval)duration animations:(NSArray<CAAnimation *> *)animations;

@end
