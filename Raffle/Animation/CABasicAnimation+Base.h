//
//  CABasicAnimation+Base.h
//  Raffle
//
//  Created by Killua Liu on 8/29/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CABasicAnimation (Base)

+ (instancetype)animationWithDuration:(NSTimeInterval)duration keyPath:(NSString *)keyPath;

@end
