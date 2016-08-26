//
//  KLBaseTransition.h
//  Raffle
//
//  Created by Killua Liu on 8/26/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLBaseTransition : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

+ (instancetype)transitionWithInteractive:(BOOL)interactive;    // Must retain the instance with property

@property (nonatomic, assign, readonly, getter=isPresenting) BOOL presenting;
@property (nonatomic, assign, readonly, getter=isInteractive) BOOL interactive;
@property (nonatomic, assign, readonly, getter=isModalTransition) BOOL modalTransition;     // Modal(Present) or Navigation(Push/Pop)

@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, strong, readonly) id <UIViewControllerContextTransitioning> transitionContext;

// Below methods need overwrite by subclass if needed
- (void)animateModalTransition:(id <UIViewControllerContextTransitioning>)transitionContext;
- (void)animateNavigationTransition:(id <UIViewControllerContextTransitioning>)transitionContext;

@end
