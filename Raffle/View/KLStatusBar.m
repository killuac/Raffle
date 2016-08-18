//
//  KLStatusBar.m
//  Raffle
//
//  Created by Killua Liu on 8/16/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLStatusBar.h"

#pragma mark - KLStatusWindow
@implementation KLStatusWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (point.y > 0 && point.y < self.statusBarHeight) {
        return [super hitTest:point withEvent:event];
    }
    return nil;
}

@end


#pragma mark - KLStatusBar
NSTimeInterval const KLStatusBarScrollDelay = 1.0;

@interface KLStatusBar ()

@property (nonatomic, strong) UIWindow *statusBarWindow;
@property (nonatomic, strong) UIView *snapshotView;
@property (nonatomic, strong) UILabel *notificationLabel;

@property (nonatomic, strong) NSLayoutConstraint *statusBarTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *statusBarHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *labelTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *labelHeightConstraint;

@property (nonatomic, assign) NSTimeInterval duration;  // Showing duration

@end

@implementation KLStatusBar

static KLStatusBar *sharedStatusBar = nil;

#pragma mark - Lifecycle
- (instancetype)init
{
    if (self = [super init]) {
        [self prepareForUI];
        [self addObservers];
        [self addConstraints];
    }
    return self;
}

- (void)prepareForUI
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor blueColor];
    [self.statusBarWindow.rootViewController.view addSubview:self];
    
    self.snapshotView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
    self.snapshotView.translatesAutoresizingMaskIntoConstraints = NO;
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        [self addSubview:self.snapshotView];
    }
}

- (UIWindow *)statusBarWindow
{
    if (_statusBarWindow) return _statusBarWindow;
    
    _statusBarWindow = [[KLStatusWindow alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
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
    
    _notificationLabel = [UILabel newAutoLayoutView];
    _notificationLabel.userInteractionEnabled = YES;
    _notificationLabel.textAlignment = NSTextAlignmentCenter;
    _notificationLabel.font = [UIFont defaultFont];
    _notificationLabel.textColor = [UIColor blackColor];
    _notificationLabel.isAutoScroll = YES;
//    _notificationLabel.backgroundColor = [UIColor whiteColor];
    [self.statusBarWindow.rootViewController.view addSubview:_notificationLabel];
    [self.notificationLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismiss:)]];
    
    return _notificationLabel;
}

- (void)addConstraints
{
    [self constraintsEqualWidthWithSuperView];
    self.statusBarTopConstraint = [NSLayoutConstraint constraintTopWithItem:self];
    self.statusBarHeightConstraint = [NSLayoutConstraint constraintHeightWithItem:self constant:self.statusBarHeight];
    self.statusBarTopConstraint.active = self.statusBarHeightConstraint.active = YES;
    
    if (self.snapshotView.superview) {
        [self.snapshotView constraintsEqualWidthWithSuperView];
        [NSLayoutConstraint constraintTopWithItem:self.snapshotView].active = YES;
    }
    
    [self.notificationLabel constraintsEqualWidthWithSuperView];
    self.labelTopConstraint = [NSLayoutConstraint constraintTopWithItem:self.notificationLabel];
    self.labelTopConstraint.constant = -self.statusBarHeight;
    self.labelHeightConstraint = [NSLayoutConstraint constraintHeightWithItem:self.notificationLabel constant:self.statusBarHeight];
    self.labelTopConstraint.active = self.labelHeightConstraint.active = YES;
}

#pragma mark - Orientation observer
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsUpdateConstraints) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
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
    sharedStatusBar = [KLStatusBar newAutoLayoutView];
    [sharedStatusBar showWithMessage:message];
}

+ (void)dismiss
{
    [sharedStatusBar dismissStatusBar];
}


- (void)updateConstraints
{
    self.statusBarTopConstraint.constant = self.statusBarHeight;
    self.statusBarHeightConstraint.constant = 0;
    self.labelTopConstraint.constant = 0;
    [super updateConstraints];
}

- (void)showWithMessage:(NSString *)message
{
    self.notificationLabel.text = message;
    NSTimeInterval scrollDuration = self.notificationLabel.scrollDuration;
    NSTimeInterval delay = (scrollDuration > 0) ? scrollDuration + KLStatusBarScrollDelay : self.duration;
    
    [UIView animateWithDefaultDuration:^{
        [self.statusBarWindow.rootViewController.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        KLDispatchMainAfter(delay, ^{
            [self.class dismiss];
        });
    }];
}

- (void)dismissStatusBar
{
    self.statusBarHeightConstraint.constant = self.statusBarHeight;
    [UIView animateWithDefaultDuration:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.statusBarWindow.hidden = YES;
        self.statusBarWindow = nil;
        sharedStatusBar = nil;
    }];
}

- (NSTimeInterval)duration
{
    NSTimeInterval duration = self.notificationLabel.text.length * 0.06 + 0.5;
    if ([self.notificationLabel.text containsUnicodeCharacter]) {
        duration *= 2;  // Chinese or Japanese
    }
    return duration;
}

- (void)tapToDismiss:(UITapGestureRecognizer *)recognizer
{
    [self.class dismiss];
}

@end
