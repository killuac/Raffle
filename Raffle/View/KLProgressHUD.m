//
//  KLProgressHUD.m
//  Raffle
//
//  Created by Killua Liu on 12/27/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLProgressHUD.h"

@interface KLProgressHUD ()

@property (nonatomic, strong) UIView *dimmingView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, assign, getter=isShowing) BOOL showing;

@end

@implementation KLProgressHUD

static KLProgressHUD *sharedProgressHUD = nil;
+ (KLProgressHUD *)sharedProgressHUD
{
    if (!sharedProgressHUD) {
        sharedProgressHUD = [KLProgressHUD new];
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
        self.frame = [UIApplication sharedApplication].keyWindow.bounds;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        [self addSubview:self.dimmingView];
    }
    return self;
}

- (void)showActivity
{
    self.showing = YES;
    [self addSubview:self.activityView];
    [self.activityView constraintsCenterInSuperview];
    [self setHidden:NO animated:YES];
}

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
    self.dimmingView = nil;
    self.activityView = nil;
    
    self.showing = NO;
    sharedProgressHUD = nil;
}

- (UIView *)dimmingView
{
    if (_dimmingView) return _dimmingView;
    
    _dimmingView = [[UIView alloc] initWithFrame:self.bounds];
    _dimmingView.backgroundColor = [UIColor dimmingBackgroundColor];
    _dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return _dimmingView;
}

- (UIActivityIndicatorView *)activityView
{
    if (_activityView) return _activityView;
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityView.translatesAutoresizingMaskIntoConstraints = NO;
    [_activityView startAnimating];
    return _activityView;
}

@end
