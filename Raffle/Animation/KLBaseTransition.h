//
//  KLBaseTransition.h
//  Raffle
//
//  Created by Killua Liu on 8/26/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KLTransitionOrientation) {
    KLTransitionOrientationHorizontal,
    KLTransitionOrientationVertical
};

@interface KLBaseTransition : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

+ (instancetype)transitionWithGestureEnabled:(BOOL)gestureEnabled;  // Must retain the instance with property

@property (nonatomic, assign) KLTransitionOrientation transitionOrientation;    // KLTransitionOrientationVertical by default
@property (nonatomic, assign, readonly) BOOL isVertical;

@property (nonatomic, assign, readonly, getter=isPresenting) BOOL presenting;
@property (nonatomic, assign, readonly, getter=isInteractive) BOOL interactive;
@property (nonatomic, assign, readonly, getter=isModalTransition) BOOL modalTransition;     // Modal(Present) or Navigation(Push/Pop)

@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, weak, readonly) id <UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, weak, readonly) UINavigationController *navigationController;

// Below methods need overwrite by subclass if needed
- (void)animateModalTransitionFromView:(UIView *)fromView toView:(UIView *)toView;
- (void)animateNavigationTransitionFromView:(UIView *)fromView toView:(UIView *)toView;

@end
