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

@end

@implementation KLProgressHUD

static KLProgressHUD *sharedProgressHUD = nil;
+ (instancetype)sharedProgressHUD
{
    if (!sharedProgressHUD) {
        sharedProgressHUD = [KLProgressHUD new];
    }
    return sharedProgressHUD;
}

+ (void)showActivity
{
    [self.sharedProgressHUD showActivity];
}

+ (void)dismiss
{
    [self.sharedProgressHUD dismiss];
}

#pragma mark - Life cycle
- (instancetype)init
{
    if (self = [super init]) {
        self.frame = [UIApplication sharedApplication].keyWindow.bounds;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    return self;
}

- (void)showActivity
{
    [self addSubview:self.dimmingView];
    
    [UIView animateWithDefaultDuration:^{
        self.dimmingView.alpha = 1;
    } completion:^(BOOL finished) {
        [self addSubview:self.activityView];
        [self.activityView constraintsCenterInSuperview];
    }];
}

- (void)dismiss
{
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
    sharedProgressHUD = nil;
}

- (UIView *)dimmingView
{
    if (_dimmingView) return _dimmingView;
    
    _dimmingView = [[UIView alloc] initWithFrame:self.bounds];
    _dimmingView.alpha = 0;
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
