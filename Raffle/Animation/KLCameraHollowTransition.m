//
//  KLCameraHollowTransition.m
//  Raffle
//
//  Created by Killua Liu on 12/28/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLCameraHollowTransition.h"

@implementation KLCameraHollowTransition

- (void)animateModalTransitionFromView:(UIView *)fromView toView:(UIView *)toView
{
    UIView *containerView = self.transitionContext.containerView;
    
    
    CATransition *cameraAnimation = [CATransition animation];
    cameraAnimation.duration = self.animationDuration;
    cameraAnimation.timingFunction = UIViewAnimationCurveEaseInOut;

    if (self.isPresenting) {
        cameraAnimation.type = @"cameraIrisHollowOpen";
    } else {
        cameraAnimation.type = @"cameraIrisHollowClose";
    }
    
    DECLARE_WEAK_SELF;
    [fromView.layer addAnimation:cameraAnimation forKey:@"cameraAnimation"];
    [cameraAnimation setCompletionBlock:^(BOOL isFinished) {
        [containerView addSubview:toView];
        [welf.transitionContext completeTransition:!welf.transitionContext.transitionWasCancelled];
    }];
}

@end
