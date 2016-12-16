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


@protocol KLBaseTransitionPresentationDelegate <NSObject>

@optional
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting;

@end


@interface KLBaseTransition : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

+ (instancetype)transition;     // Default NO
+ (instancetype)transitionWithGestureEnabled:(BOOL)gestureEnabled;  // Must retain the instance with property
- (instancetype)initWithGestureEnabled:(BOOL)gestureEnabled;

@property (nonatomic, assign) KLTransitionOrientation transitionOrientation;    // KLTransitionOrientationVertical by default
@property (nonatomic, readonly) BOOL isVertical;

@property (nonatomic, readonly, getter=isPresenting) BOOL presenting;
@property (nonatomic, readonly, getter=isInteractive) BOOL interactive;
@property (nonatomic, readonly, getter=isModalTransition) BOOL modalTransition;     // Modal(Present) or Navigation(Push/Pop)

@property (nonatomic, weak) id <KLBaseTransitionPresentationDelegate> presentationDelegate;

@property (nonatomic, readonly) NSTimeInterval animationDuration;
@property (nonatomic, readonly) id <UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, readonly) UINavigationController *navigationController;

// Below methods need overwrite by subclass if needed
- (void)animateModalTransitionFromView:(UIView *)fromView toView:(UIView *)toView;
- (void)animateNavigationTransitionFromView:(UIView *)fromView toView:(UIView *)toView;

@end
