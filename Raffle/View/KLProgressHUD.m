//
//  KLProgressHUD.m
//  Raffle
//
//  Created by Killua Liu on 12/27/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLProgressHUD.h"
#import "KLPieProgressView.h"

@interface KLProgressHUD ()

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) KLPieProgressView *progressView;

@property (nonatomic, assign, getter=isShowing) BOOL showing;

@end

@implementation KLProgressHUD

static KLProgressHUD *sharedProgressHUD = nil;
+ (KLProgressHUD *)sharedProgressHUD
{
    if (!sharedProgressHUD) {
        sharedProgressHUD = [KLProgressHUD new];
        sharedProgressHUD.frame = UIApplication.sharedApplication.keyWindow.bounds;
        sharedProgressHUD.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [UIApplication.sharedApplication.keyWindow addSubview:sharedProgressHUD];
    }
    return sharedProgressHUD;
}

+ (void)showActivity
{
    dispatch_block_t block = ^{
        if (self.sharedProgressHUD.isShowing) {
            [self.sharedProgressHUD dismissAnimated:NO];
        }
        [self.sharedProgressHUD performSelector:@selector(showActivity) withObject:nil afterDelay:[CATransaction animationDuration]];
    };
    NSThread.isMainThread ? block() : KLDispatchMainAsync(block);
}

+ (void)showProgress:(CGFloat)progress
{
    dispatch_block_t block = ^{
        [self.sharedProgressHUD showProgress:progress];
    };
    NSThread.isMainThread ? block() : KLDispatchMainAsync(block);
}

+ (void)dismiss
{
    dispatch_block_t block = ^{
        [self cancelPreviousPerformRequestsWithTarget:self.sharedProgressHUD];
        [self.sharedProgressHUD dismissAnimated:YES];
    };
    NSThread.isMainThread ? block() : KLDispatchMainAsync(block);
}

#pragma mark - Life cycle
- (instancetype)init
{
    if (self = [super init]) {
        self.alpha = 0;
        [self addDimBackground];
    }
    return self;
}

#pragma mark - Activity view
- (UIActivityIndicatorView *)activityView
{
    if (_activityView) return _activityView;
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityView.translatesAutoresizingMaskIntoConstraints = NO;
    [_activityView startAnimating];
    return _activityView;
}

- (void)showActivity
{
    self.showing = YES;
    self.userInteractionEnabled = NO;
    [self addSubview:self.activityView];
    [self setAnimatedHidden:NO completion:nil];
    [self.activityView constraintsCenterInSuperview];
}

#pragma mark - Progress view
- (KLPieProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [KLPieProgressView newAutoLayoutView];
    }
    return _progressView;
}

- (void)showProgress:(CGFloat)progress
{
    if (self.isShowing) {
        [self.progressView setProgress:progress animated:YES];
        return;
    }
    
    self.showing = YES;
    [self addSubview:self.progressView];
    [self setAnimatedHidden:NO completion:nil];
    [self.progressView constraintsCenterInSuperview];
}

#pragma mark - Dismiss
- (void)dismissAnimated:(BOOL)animated
{
    if (!animated) {
        [self removeFromSuperview];
        [self resetAllSubviews];
        return;
    }
    
    [UIView animateWithDefaultDuration:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self resetAllSubviews];
    }];
}

- (void)resetAllSubviews
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.activityView = nil;
    self.progressView = nil;
    sharedProgressHUD = nil;
}

@end
