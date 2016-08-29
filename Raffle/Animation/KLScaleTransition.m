//
//  KLScaleTransition.m
//  Raffle
//
//  Created by Killua Liu on 8/26/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLScaleTransition.h"

@interface KLScaleTransition ()

@end

@implementation KLScaleTransition

- (void)animateModalTransitionFromView:(UIView *)fromView toView:(UIView *)toView
{
    UIView *containerView = self.transitionContext.containerView;
    
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    if (self.isPresenting) {
        [containerView addSubview:toView];
        CATransform3D scaleTransform = CATransform3DMakeScale(0.94, 0.94, 1);
        scaleTransform.m34 = 1.0/-500.0;
        toView.layer.transform = self.isVertical ? CATransform3DMakeTranslation(0, toView.height, 0) : CATransform3DMakeTranslation(toView.width, 0, 0);
        [UIView animateWithDuration:self.duration animations:^{
            toView.layer.transform = CATransform3DIdentity;
            fromView.alpha = 0.7;
            fromView.layer.transform = scaleTransform;
        } completion:^(BOOL finished) {
            [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
        }];
    }
    else {
        [containerView insertSubview:toView belowSubview:fromView];
        
        fromView.layer.shadowColor = [UIColor blackColor].CGColor;
        fromView.layer.shadowOpacity = 0.3;
        fromView.layer.shadowOffset = self.isVertical ? CGSizeMake(0, -3) : CGSizeMake(-3, 0);
        fromView.layer.shadowRadius = 5.0;
        
        [UIView animateWithDuration:self.duration animations:^{
            toView.alpha = 1;
            toView.layer.transform = CATransform3DIdentity;
            fromView.layer.transform = self.isVertical ? CATransform3DMakeTranslation(0, fromView.height, 0) : CATransform3DMakeTranslation(fromView.width, 0, 0);
        } completion:^(BOOL finished) {
            [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
        }];
    }
}

@end
