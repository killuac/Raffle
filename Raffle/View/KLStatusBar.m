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

- (CGFloat)statusBarHeight
{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? [super statusBarHeight] : 20;
}

@end


#pragma mark - KLStatusBar
NSTimeInterval const KLStatusBarScrollDelay = 1.0;

@interface KLStatusBar ()

@property (nonatomic, strong) UIWindow *statusBarWindow;
@property (nonatomic, strong) UIView *snapshotView;
@property (nonatomic, strong) UILabel *notificationLabel;

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign, readonly) NSTimeInterval duration;    // Showing duration

@end

@implementation KLStatusBar

static KLStatusBar *sharedStatusBar = nil;

#pragma mark - Lifecycle
- (instancetype)init
{
    if (self = [super init]) {
        [self prepareForUI];
        [self addObservers];
    }
    return self;
}

- (CGFloat)statusBarHeight
{
    return self.statusBarWindow.statusBarHeight;
}

- (void)prepareForUI
{
    self.clipsToBounds = YES;
    self.size = CGSizeMake(SCREEN_WIDTH, self.statusBarHeight);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.statusBarWindow addSubview:self];
    [self.statusBarWindow addSubview:self.notificationLabel];
    
    self.snapshotView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
    [self addSubview:self.snapshotView];
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
    
    _notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -self.statusBarHeight, SCREEN_WIDTH, self.statusBarHeight)];
    _notificationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _notificationLabel.userInteractionEnabled = YES;
    _notificationLabel.textAlignment = NSTextAlignmentCenter;
    _notificationLabel.font = [UIFont defaultFont];
    _notificationLabel.textColor = [UIColor blackColor];
    _notificationLabel.isAutoScroll = YES;
    _notificationLabel.backgroundColor = [UIColor whiteColor];
    [_notificationLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismiss:)]];
    
    return _notificationLabel;
}

#pragma mark - Orientation observer
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusBarFrame) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)deviceOrientationDidChange
{
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        self.hidden = NO;
        if (!self.snapshotView.superview)
            [self addSubview:self.snapshotView];    // Replace animation
    } else {
        self.hidden = YES;
        [self.snapshotView removeFromSuperview];    // Overlay animation
    }
    
    [self updateStatusBarFrame];
}

- (void)updateStatusBarFrame
{
    self.hidden = YES;
    self.height = self.isShowing ? 0 : self.statusBarHeight;
    self.notificationLabel.height = self.statusBarHeight;
}

#pragma mark - Notification message
+ (void)showNotificationWithMessage:(NSString *)message
{
    if (sharedStatusBar.isShowing) {
        [sharedStatusBar dismissAnimated:NO];
    }
    sharedStatusBar = [KLStatusBar new];
    [sharedStatusBar showWithMessage:message];
}

+ (void)dismiss
{
    [sharedStatusBar dismissAnimated:YES];
}

- (void)showWithMessage:(NSString *)message
{
    sharedStatusBar.isShowing = YES;
    
    self.notificationLabel.text = message;
    [self.notificationLabel sizeToFit];
    self.notificationLabel.height = self.statusBarHeight;
    NSTimeInterval scrollDuration = self.notificationLabel.scrollDuration;
    NSTimeInterval delay = (scrollDuration > 0) ? scrollDuration + KLStatusBarScrollDelay : self.duration;
    
    [UIView animateWithDefaultDuration:^{
        self.notificationLabel.top = 0;
        self.frame = CGRectMake(0, self.statusBarHeight, self.width, 0);
    } completion:^(BOOL finished) {
        KLDispatchMainAfter(delay, ^{
            [self dismissAnimated:YES];
        });
    }];
}

- (void)dismissAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDefaultDuration:^{
            self.notificationLabel.top = -self.statusBarHeight;
            self.frame = CGRectMake(0, 0, self.width, self.statusBarHeight);
        } completion:^(BOOL finished) {
            [self resetNil];
        }];
    } else {
        [self resetNil];
    }
}

- (void)resetNil
{
    self.statusBarWindow.hidden = YES;
    self.statusBarWindow = nil;
    
    sharedStatusBar.isShowing = NO;
    sharedStatusBar = nil;
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
