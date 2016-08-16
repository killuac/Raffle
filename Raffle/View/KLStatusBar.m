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
@property (nonatomic, strong) UILabel *notificationLabel;

@end

@implementation KLStatusBar

#pragma mark - Lifecycle
static id sharedStatusBar = nil;
+ (instancetype)sharedStatusBar
{
    KLDispatchOnce(^{
        sharedStatusBar = [self newAutoLayoutView];
    });
    return sharedStatusBar;
}

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
    self.transform = CGAffineTransformMakeTranslation(0, -self.statusBarHeight);
    [self.statusBarWindow.rootViewController.view addSubview:self];
    [self.statusBarWindow.rootViewController.view sendSubviewToBack:self];
    
    self.snapshotView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        [self addSubview:self.snapshotView];
    }
    
    [self setNeedsUpdateConstraints];
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

- (UILabel *)notificationLabel
{
    if (_notificationLabel) return _notificationLabel;
    
    _notificationLabel = [UILabel new];
    _notificationLabel.textAlignment = NSTextAlignmentCenter;
    _notificationLabel.font = [UIFont defaultFont];
    _notificationLabel.textColor = [UIColor titleColor];
    [self addSubview:_notificationLabel];
    
    return _notificationLabel;
}

- (void)updateConstraints
{
    [self constraintsEqualWidthWithSuperView];
    [NSLayoutConstraint constraintHeightWithItem:self constant:self.statusBarHeight].active = YES;
    
    [self.snapshotView constraintsEqualWidthWithSuperView];
    [NSLayoutConstraint constraintTopWithItem:self.snapshotView].active = YES;
    
    [self.notificationLabel constraintsCenterInSuperview];
    
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
    KLStatusBar *statusBar = [KLStatusBar sharedStatusBar];
    statusBar.notificationLabel.text = message;
    
    [UIView animateWithDefaultDuration:^{
        statusBar.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        KLDispatchMainAfter(3, ^{
            [self dismiss];
        });
    }];
}

+ (void)dismiss
{
    KLStatusBar *statusBar = [KLStatusBar sharedStatusBar];
    [UIView animateWithDefaultDuration:^{
        statusBar.transform = CGAffineTransformMakeTranslation(0, -statusBar.statusBarHeight);
    } completion:^(BOOL finished) {
        [statusBar removeFromSuperview];
        statusBar.statusBarWindow.hidden = YES;
        statusBar.statusBarWindow = nil;
    }];
}

- (void)tapToDismiss:(UITapGestureRecognizer *)recognizer
{
    [self.class dismiss];
}

@end
