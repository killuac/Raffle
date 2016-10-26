//
//  KLDrawBoxTransition.m
//  Raffle
//
//  Created by Killua Liu on 10/26/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawBoxTransition.h"

@implementation KLDrawBoxTransition

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return KLViewDefaultAnimationDuration;
}

- (void)animateNavigationTransitionFromView:(UIView *)fromView toView:(UIView *)toView
{
    UIView *containerView = self.transitionContext.containerView;
    
//    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    if (self.isPresenting) {
        [containerView addSubview:toView];
        [UIView animateWithDuration:self.duration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:0 animations:^{
            toView.transform = CGAffineTransformMakeScale(1.01, 1.0);
        } completion:^(BOOL finished) {
            toView.transform = CGAffineTransformIdentity;
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
