//
//  KLStatusBar.m
//  Raffle
//
//  Created by Killua Liu on 8/16/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLStatusBar.h"

@interface KLStatusBar ()

@property (nonatomic, strong) UIWindow *statusBarWindow;
@property (nonatomic, strong) UIView *snapshotView;

@end

@implementation KLStatusBar

#pragma mark - Lifecycle
- (instancetype)init
{
    if (self = [super init]) {
        [self prepareForUI];
        [self addObservers];
    }
    return self;
}

- (void)prepareForUI
{
    self.clipsToBounds = YES;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.statusBarWindow.rootViewController.view addSubview:self];
    [self.statusBarWindow.rootViewController.view sendSubviewToBack:self];
    
    self.snapshotView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        [self addSubview:self.snapshotView];
    }
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismiss:)]];
}

- (UIWindow *)statusBarWindow
{
    if (_statusBarWindow) return _statusBarWindow;
    
    _statusBarWindow = [[UIWindow alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    _statusBarWindow.hidden = NO;
    _statusBarWindow.windowLevel = UIWindowLevelStatusBar;
    _statusBarWindow.backgroundColor = [UIColor clearColor];
    _statusBarWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _statusBarWindow.rootViewController = [UIViewController new];
    
    return _statusBarWindow;
}

- (void)updateConstraints
{
    
    [super updateConstraints];
}

#pragma mark - Orientation observer
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        if (!self.snapshotView.superview)
            [self insertSubview:self.snapshotView atIndex:0];   // Replace animation
    } else {
        [self.snapshotView removeFromSuperview];                // Overlay animation
    }
}

#pragma mark - Notification message
+ (void)showNotificationWithMessage:(NSString *)message
{
    
}

+ (void)dismiss
{
    
}

- (void)tapToDismiss:(UITapGestureRecognizer *)recognizer
{
    [self.class dismiss];
}

@end
