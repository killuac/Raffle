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

#pragma mark - UIViewControllerAnimatedTransitioning
- (void)animateModalTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = transitionContext.containerView;
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    if (self.isPresenting) {
        [containerView addSubview:fromView];
        [containerView addSubview:toView];
        
    } else {
        [containerView addSubview:toView];
        [containerView addSubview:fromView];
    }
    
    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
}

- (void)animateNavigationTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isPresenting) {
        
    } else {
        
    }
}

#pragma mark - UIViewControllerInteractiveTransitioning
//- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext
//{
//	
//}
//
//- (void)updateInteractiveTransition:(CGFloat)percentComplete
//{
//	
//}
//
//- (void)finishInteractiveTransition
//{
//	
//}
//
//- (void)cancelInteractiveTransition
//{
//	
//}


@end
