//
//  KLSwapTransition.m
//  Raffle
//
//  Created by Killua Liu on 9/25/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLSwapTransition.h"

#define MINIMUM_SCALE 0.001

@implementation KLSwapTransition

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0;
}

- (void)animateModalTransitionFromView:(UIView *)fromView toView:(UIView *)toView
{
    UIView *containerView = self.transitionContext.containerView;
    NSArray<UIView *> *snapshotViews = [self createSnapshotViewsBaseView:self.isPresenting ? fromView : toView];
    UIView *firstView = snapshotViews.firstObject;
    UIView *secondView = snapshotViews.lastObject;
    
    if (self.isPresenting) {
        [fromView removeFromSuperview];
        [containerView insertSubview:toView belowSubview:firstView];
        toView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        [UIView animateWithDuration:self.duration animations:^{
            toView.transform = CGAffineTransformIdentity;
            firstView.transform = self.isVertical ? CGAffineTransformMakeScale(1, MINIMUM_SCALE) : CGAffineTransformMakeScale(MINIMUM_SCALE, 1);
            secondView.transform = self.isVertical ? CGAffineTransformMakeScale(1, MINIMUM_SCALE) : CGAffineTransformMakeScale(MINIMUM_SCALE, 1);
        } completion:^(BOOL finished) {
            [snapshotViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
        }];
    }
    else {
        [containerView insertSubview:toView belowSubview:fromView];
        toView.hidden = YES;
        firstView.transform = self.isVertical ? CGAffineTransformMakeScale(1, MINIMUM_SCALE) : CGAffineTransformMakeScale(MINIMUM_SCALE, 1);
        secondView.transform = self.isVertical ? CGAffineTransformMakeScale(1, MINIMUM_SCALE) : CGAffineTransformMakeScale(MINIMUM_SCALE, 1);
        [UIView animateWithDuration:self.duration animations:^{
            fromView.transform = CGAffineTransformMakeScale(0.8, 0.8);
            firstView.transform = CGAffineTransformIdentity;
            secondView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            toView.hidden = NO;
            [snapshotViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
        }];
    }
}

- (NSArray<UIView *> *)createSnapshotViewsBaseView:(UIView *)view
{
    UIView *containerView = self.transitionContext.containerView;
    
    CGRect firstFrame, secondFrame;
    if (self.isVertical) {
        firstFrame = CGRectMake(0, 0, view.width, view.height/2);
        secondFrame = CGRectMake(0, view.height/2, view.width, view.height/2);
    } else {
        firstFrame = CGRectMake(0, 0, view.width/2, view.height);
        secondFrame = CGRectMake(view.width/2, 0, view.width/2, view.height);
    }
    
    UIView *firstView = [view resizableSnapshotViewFromRect:firstFrame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    UIView *secondView = [view resizableSnapshotViewFromRect:secondFrame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    firstView.frame = firstFrame;
    secondView.frame = secondFrame;
    [containerView addSubview:firstView];
    [containerView addSubview:secondView];
    
    if (self.isVertical) {
        firstView.top = -view.height/4;
        secondView.top = view.height*3/4;
        firstView.layer.anchorPoint = CGPointMake(0.5, 0);
        secondView.layer.anchorPoint = CGPointMake(0.5, 1);
    } else {
        firstView.left = -view.width/4;
        secondView.left = view.width*3/4;
        firstView.layer.anchorPoint = CGPointMake(0, 0.5);
        secondView.layer.anchorPoint = CGPointMake(1, 0.5);
    }
    
    return @[firstView, secondView];
}

@end
