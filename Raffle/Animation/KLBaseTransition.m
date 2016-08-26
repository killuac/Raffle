//
//  KLBaseTransition.m
//  Raffle
//
//  Created by Killua Liu on 8/26/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLBaseTransition.h"

@interface KLBaseTransition ()

@property (nonatomic, weak) UIViewController *viewController;   // Presented VC or Navigation Controller
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation KLBaseTransition

+ (instancetype)transitionWithInteractive:(BOOL)interactive
{
    return [[self alloc] initWithInteractive:interactive];
}

- (instancetype)initWithInteractive:(BOOL)interactive
{
    if (self = [super init]) {
        _interactive = interactive;
    }
    return self;
}

- (void)dealloc
{
    [self removeInteractiveGesture];
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)duration
{
    return [self transitionDuration:self.transitionContext];
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return [CATransaction animationDuration];
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    _transitionContext = transitionContext;
    if (self.isModalTransition) {
        [self animateModalTransition:transitionContext];
    } else {
        [self animateNavigationTransition:transitionContext];
    }
}

- (void)animateModalTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
//  Implement by subclass
}

- (void)animateNavigationTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
//  Implement by subclass
}

#pragma mark - Interactive gesture
- (void)addInteractiveGestureToViewController:(UIViewController *)viewController
{
    self.viewController = viewController;
    if (self.isModalTransition) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    } else {
        self.panGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        ((UIScreenEdgePanGestureRecognizer *)self.panGesture).edges = UIRectEdgeLeft;
    }
    [viewController.view addGestureRecognizer:self.panGesture];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    UIView *recognizerView = recognizer.view;
    CGPoint location = [recognizer locationInView:recognizerView];
    CGPoint velocity = [recognizer velocityInView:recognizerView];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (self.isModalTransition) {
                if (velocity.x != 0) return;
                [self.viewController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [(UINavigationController *)self.viewController popViewControllerAnimated:YES];
            }
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGFloat ratio = self.isModalTransition ? (location.y / recognizerView.height) : (location.x / recognizerView.width);
            [self updateInteractiveTransition:ratio];
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            BOOL flag = self.isModalTransition ? location.y > recognizerView.height/3 : location.x > recognizerView.width/2;
            if (self.presenting) {
                if (flag) {
                    [self finishInteractiveTransition];
                } else {
                    [self cancelInteractiveTransition];
                }
            } else {
                if (!flag) {
                    [self finishInteractiveTransition];
                } else {
                    [self cancelInteractiveTransition];
                }
            }
            break;
        }
            
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            [self cancelInteractiveTransition];
            break;
            
        default:
            break;
    }
}

- (void)removeInteractiveGesture
{
    [self.viewController.view removeGestureRecognizer:self.panGesture];
    self.panGesture = nil;
    self.viewController = nil;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presentedVC
                                                                   presentingController:(UIViewController *)presentingVC
                                                                       sourceController:(UIViewController *)sourceVC
{
    _presenting = YES; _modalTransition = YES;
    if (self.isInteractive) {
        [self addInteractiveGestureToViewController:presentedVC];
    }
    
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissedVC
{
    _presenting = NO; _modalTransition = YES;
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)transitionAnimator
{
    return self.isInteractive ? self : nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)transitionAnimator
{
    return self.isInteractive ? self : nil;
}

#pragma mark - UINavigationControllerDelegate
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationNone) return nil;
    
    NSUInteger fromIndex = [navigationController.viewControllers indexOfObject:fromVC];
    NSUInteger toIndex = [navigationController.viewControllers indexOfObject:toVC];
    _presenting = (toIndex > fromIndex); _modalTransition = NO;
    if (self.isInteractive) {
        [self addInteractiveGestureToViewController:navigationController];
    }
    
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)transitionAnimator
{
    return self.isInteractive ? self : nil;
}

@end
