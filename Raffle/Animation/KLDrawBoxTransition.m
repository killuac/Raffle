//
//  KLDrawBoxTransition.m
//  Raffle
//
//  Created by Killua Liu on 10/26/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawBoxTransition.h"

@implementation KLDrawBoxTransition

- (void)animateNavigationTransitionFromView:(UIView *)fromView toView:(UIView *)toView
{
    UIView *containerView = self.transitionContext.containerView;
    
    if (self.isPresenting) {
        [containerView addSubview:fromView];
        [containerView addSubview:toView];
        
        UICollectionView *fromCollectionView = fromView.subviews.firstObject;
        UICollectionView *toCollectionView = toView.subviews.firstObject;
        toCollectionView.backgroundColor = [UIColor clearColor];
        
        [UIView animateWithDuration:self.duration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:0 animations:^{
            fromCollectionView.alpha = 0;
            [toCollectionView performBatchUpdates:^{
                [toCollectionView setCollectionViewLayout:toCollectionView.collectionViewLayout animated:NO];
            } completion:nil];
        } completion:^(BOOL finished) {
            fromCollectionView.alpha = 1;
            toCollectionView.backgroundColor = [UIColor darkBackgroundColor];
            [fromView removeFromSuperview];
            [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
        }];
    }
    else {
        [containerView insertSubview:toView belowSubview:fromView];
        
        UICollectionView *collectionView = fromView.subviews.firstObject;
        [UIView animateWithDuration:self.duration animations:^{
            [collectionView performBatchUpdates:^{
                [collectionView setCollectionViewLayout:collectionView.collectionViewLayout animated:NO];
            } completion:nil];
        } completion:^(BOOL finished) {
            [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
        }];
    }
}

@end
