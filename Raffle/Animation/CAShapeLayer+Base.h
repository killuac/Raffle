//
//  CAShapeLayer+Base.h
//  Raffle
//
//  Created by Killua Liu on 8/29/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAShapeLayer (Base)

+ (instancetype)layerWithPath:(CGPathRef)path;

@end
