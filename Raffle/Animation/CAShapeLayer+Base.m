//
//  CAShapeLayer+Base.m
//  Raffle
//
//  Created by Killua Liu on 8/29/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "CAShapeLayer+Base.h"

@implementation CAShapeLayer (Base)

+ (instancetype)layerWithPath:(CGPathRef)path
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path;
    return shapeLayer;
}

@end
