//
//  KLCircleTransition.m
//  Raffle
//
//  Created by Killua Liu on 8/26/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLCircleTransition.h"

@implementation KLCircleTransition

- (void)animateModalTransitionFromView:(UIView *)fromView toView:(UIView *)toView
{
    UIView *containerView = self.transitionContext.containerView;
    CGFloat radius = KLPointDistance(CGPointZero, containerView.center);
    CGPathRef startPath = [UIBezierPath bezierPathWithArcCenter:containerView.center radius:0.01 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
    CGPathRef endPath = [UIBezierPath bezierPathWithArcCenter:containerView.center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layerWithPath:endPath];
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithDuration:self.animationDuration keyPath:@"path"];
    // Avoid screen flash
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fillMode = kCAFillModeBoth;
    
    if (self.isPresenting) {
        [containerView addSubview:toView];
        toView.layer.mask = maskLayer;
        
        pathAnimation.fromValue = (__bridge id)startPath;
        pathAnimation.toValue = (__bridge id)endPath;
    } else {
        [containerView insertSubview:toView belowSubview:fromView];
        fromView.layer.mask = maskLayer;
        
        pathAnimation.fromValue = (__bridge id)endPath;
        pathAnimation.toValue = (__bridge id)startPath;
    }
    
    DECLARE_WEAK_SELF;
    [maskLayer addAnimation:pathAnimation forKey:@"pathAnimation"];
    [pathAnimation setCompletionBlock:^(BOOL isFinished) {
        fromView.layer.mask = nil;
        toView.layer.mask = nil;
        [welf.transitionContext completeTransition:!welf.transitionContext.transitionWasCancelled];
    }];
}

@end
