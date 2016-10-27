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
        [containerView addSubview:toView];
        [containerView addSubview:fromView];
        
        UICollectionView *fromCollectionView = fromView.subviews.firstObject;
        UIView *cell = fromCollectionView.visibleCells.firstObject;
        UICollectionView *collectionView = toView.subviews.firstObject;
        [UIView animateWithDuration:self.duration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:10 options:0 animations:^{
            cell.alpha = 0;
            [collectionView performBatchUpdates:^{
                [collectionView setCollectionViewLayout:collectionView.collectionViewLayout animated:NO];
            } completion:nil];
        } completion:^(BOOL finished) {
            cell.alpha = 1;
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
