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
    
//  kCAMediaTimingFunctionDefault
//    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    CABasicAnimation *fromTransformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    CABasicAnimation *toTransformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    CATransform3D translateTransform = CATransform3DMakeTranslation(0, containerView.height, 0);
//    CATransform3D scaleTransform = CATransform3DMakeScale(0.94, 0.94, 1); scaleTransform.m34 = 1.0/-500.0;
//    NSArray *fromAnimations, *toAnimations;
//    
//    if (self.isPresenting) {
//        [containerView addSubview:toView];
//        fromTransformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//        fromTransformAnimation.toValue = [NSValue valueWithCATransform3D:scaleTransform];
//        
//        opacityAnimation.fromValue = @(1.0);
//        opacityAnimation.toValue = @(0.7);
//        
//        toTransformAnimation.fromValue = [NSValue valueWithCATransform3D:translateTransform];
//        toTransformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//        
//        fromAnimations = @[fromTransformAnimation, opacityAnimation];
//        toAnimations = @[toTransformAnimation];
//    } else {
//        [containerView insertSubview:toView belowSubview:fromView];
//        fromTransformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//        fromTransformAnimation.toValue = [NSValue valueWithCATransform3D:translateTransform];
//        
//        opacityAnimation.fromValue = @(0.7);
//        opacityAnimation.toValue = @(1.0);
//        
//        toTransformAnimation.fromValue = [NSValue valueWithCATransform3D:scaleTransform];
//        toTransformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//        
//        fromAnimations = @[fromTransformAnimation];
//        toAnimations = @[toTransformAnimation, opacityAnimation];
//    }
//    
//    CAAnimationGroup * fromAnimationGroup = [CAAnimationGroup animationWithDuration:self.duration animations:fromAnimations];
//    [fromView.layer addAnimation:fromAnimationGroup forKey:@"fromAnimation"];
//    CAAnimationGroup * toAnimationGroup = [CAAnimationGroup animationWithDuration:self.duration animations:toAnimations];
//    [toView.layer addAnimation:toAnimationGroup forKey:@"toAnimation"];
//    
//    [toAnimationGroup setCompletionBlock:^(BOOL finished) {
//        [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
//    }];
    
    
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    if (self.isPresenting) {
        [containerView addSubview:toView];
        CATransform3D scaleTransform = CATransform3DMakeScale(0.94, 0.94, 1);
        scaleTransform.m34 = 1.0/-500.0;
        toView.layer.transform = CATransform3DMakeTranslation(0, toView.height, 0);
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
        [UIView animateWithDuration:self.duration animations:^{
            toView.alpha = 1;
            toView.transform = CGAffineTransformIdentity;
            fromView.layer.transform = CATransform3DMakeTranslation(0, fromView.height, 0);
        } completion:^(BOOL finished) {
            [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
        }];
    }
}

@end
