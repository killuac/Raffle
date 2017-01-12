//
//  KLBaseTransition.m
//  Raffle
//
//  Created by Killua Liu on 8/26/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLBaseTransition.h"

@interface KLBaseTransition ()

@property (nonatomic, assign) BOOL gestureEnabled;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint startLocation;

// Whether start interaction, different with gestureEnabled. Must need this flag.
@property (nonatomic, assign, getter=isInteractive) BOOL interactive;

@property (nonatomic, weak) UIViewController *presentedVC;
@property (nonatomic, weak) UIViewController *presentingVC;
@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation KLBaseTransition

+ (instancetype)transition
{
    return [[self alloc] initWithGestureEnabled:NO];
}

+ (instancetype)transitionWithGestureEnabled:(BOOL)gestureEnabled
{
    return [[self alloc] initWithGestureEnabled:gestureEnabled];
}

- (instancetype)initWithGestureEnabled:(BOOL)gestureEnabled
{
    if (self = [super init]) {
        _gestureEnabled = gestureEnabled;
        self.transitionOrientation = KLTransitionOrientationVertical;
    }
    return self;
}

- (BOOL)isVertical
{
    return self.transitionOrientation == KLTransitionOrientationVertical;
}

- (void)setPresentingVC:(UIViewController *)presentingVC presentedVC:(UIViewController *)presentedVC
{
    _presenting = YES; _modalTransition = YES;
    _presentingVC = presentingVC; _presentedVC = presentedVC;
    [self addInteractiveGestureToViewController:presentingVC];
}

- (void)setNavigationController:(UINavigationController *)navController presentedVC:(UIViewController *)presentedVC
{
    _presenting = NO; _modalTransition = NO;
    _navigationController = navController; _presentedVC = presentedVC;
    [self addInteractiveGestureToViewController:navController];
}

- (void)dealloc
{
    [self removeInteractiveGesture];
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)animationDuration
{
    return [self transitionDuration:self.transitionContext];
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.4;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    _transitionContext = transitionContext;
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];

    fromView.frame = [transitionContext initialFrameForViewController:fromVC];
    toView.frame = [transitionContext finalFrameForViewController:toVC];    // For solve orientation changed issue
    
    if (self.isModalTransition) {
        [self animateModalTransitionFromView:fromView toView:toView];
    } else {
        [self animateNavigationTransitionFromView:fromView toView:toView];
    }
}

// Up <-> Down
- (void)animateModalTransitionFromView:(UIView *)fromView toView:(UIView *)toView
{
//  Implement by subclass
}

// Left <-> Right
- (void)animateNavigationTransitionFromView:(UIView *)fromView toView:(UIView *)toView
{
//  Implement by subclass
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    _presenting = NO;
    _interactive = NO;
}

#pragma mark - Interactive gesture
- (void)addInteractiveGestureToViewController:(UIViewController *)viewController
{
    if (self.isVertical) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    } else {
        self.panGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [(id)self.panGesture setEdges:UIRectEdgeLeft];
    }
    [viewController.view addGestureRecognizer:self.panGesture];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    UIView *recognizerView = recognizer.view;
    CGPoint translation = [recognizer translationInView:recognizerView];
    CGPoint velocity = [recognizer velocityInView:recognizerView];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            _interactive = YES;
            _startLocation = [recognizer locationInView:recognizerView.superview];
            if (self.isModalTransition) {
                if (self.isPresenting) {
                    if (velocity.y < 0) {
                        [self.presentingVC presentViewController:self.presentedVC animated:YES completion:nil];
                    }
                } else {
                    if (velocity.y > 0) {
                        [self.presentedVC dismissViewControllerAnimated:YES completion:nil];
                    }
                }
            } else {
                if (self.isPresenting) {
                    [self.navigationController pushViewController:self.presentedVC animated:YES];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGFloat ratio = self.isVertical ? (translation.y / recognizerView.height) : ((translation.x + self.startLocation.x) / recognizerView.width);
            [self updateInteractiveTransition:ratio/2];
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            _interactive = NO;
            CGFloat offset = self.isVertical ? MAX(velocity.y, translation.y - self.startLocation.y/2) : MAX(velocity.x, translation.x - self.startLocation.x/2);
            BOOL isFinish = self.isVertical ? offset > recognizerView.height/4 : offset > recognizerView.width/2;
            if (isFinish) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
            break;
        }
            
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            _interactive = NO;
            [self cancelInteractiveTransition];
            break;
            
        default:
            break;
    }
}

- (void)removeInteractiveGesture
{
    [self.presentedVC.view removeGestureRecognizer:self.panGesture];
    [self.presentingVC.view removeGestureRecognizer:self.panGesture];
    [self.navigationController.view removeGestureRecognizer:self.panGesture];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presentedVC
                                                                   presentingController:(UIViewController *)presentingVC
                                                                       sourceController:(UIViewController *)sourceVC
{
    _presenting = YES; _modalTransition = YES;
    _presentedVC = presentedVC;
    if (self.gestureEnabled) {
        [self addInteractiveGestureToViewController:presentedVC];
    }
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissedVC
{
    return self;
}

// Only enable interactive gesture for dismissal
//- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
//{
//    _presenting = YES;
//    return self.isInteractive ? self : nil;
//}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    _presenting = NO;
    return self.isInteractive ? self : nil;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    if ([self.presentationDelegate respondsToSelector:@selector(presentationControllerForPresentedViewController:presentingViewController:sourceViewController:)]) {
        return [self.presentationDelegate presentationControllerForPresentedViewController:presented presentingViewController:presenting];
    }
    return nil;
}

#pragma mark - UINavigationControllerDelegate
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationNone) return nil;
    
    _navigationController = navigationController;
    NSUInteger fromIndex = [navigationController.viewControllers indexOfObject:fromVC];
    NSUInteger toIndex = [navigationController.viewControllers indexOfObject:toVC];
    _presenting = (toIndex > fromIndex); _modalTransition = NO;
    if (self.gestureEnabled) {
        [self addInteractiveGestureToViewController:navigationController];
    }
    
    return self;
}

// Only enable interactive gesture for dismissal
- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)transitionAnimator
{
    return self.isInteractive ? self : nil;
}

@end
