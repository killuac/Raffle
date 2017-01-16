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
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? super.statusBarHeight : 20;
}

@end


#pragma mark - KLStatusBar
@interface KLStatusBar ()

@property (nonatomic, strong) UIWindow *statusBarWindow;
@property (nonatomic, strong) UIView *snapshotView;
@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, assign, getter=isShowing) BOOL showing;
@property (nonatomic, readonly) NSTimeInterval duration;    // Showing duration

@property (nonatomic, strong) NSLayoutConstraint *labelCenterConstraint;

@end

@implementation KLStatusBar

static KLStatusBar *sharedStatusBar = nil;
+ (KLStatusBar *)sharedStatusBar
{
    if (!sharedStatusBar) {
        sharedStatusBar = [KLStatusBar new];
    }
    return sharedStatusBar;
}

+ (void)showWithText:(NSString *)text
{
    dispatch_block_t block = ^{
        if (self.sharedStatusBar.isShowing) {
            [self.sharedStatusBar dismissAnimated:NO];
        };
        [self.sharedStatusBar showWithMessage:text];
    };
    NSThread.isMainThread ? block() : KLDispatchMainAsync(block);
}

+ (void)dismiss
{
    dispatch_block_t block = ^{
        [self.sharedStatusBar dismissAnimated:YES];
    };
    NSThread.isMainThread ? block() : KLDispatchMainAsync(block);
}

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
    [self.statusBarWindow addSubview:self.notificationView];
    
    self.snapshotView = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
    [self addSubview:self.snapshotView];
    
    [self addContraints];
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

- (UIView *)notificationView
{
    if (_notificationView) return _notificationView;
    
    _notificationView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.statusBarHeight, SCREEN_WIDTH, self.statusBarHeight)];
    _notificationView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _notificationView.backgroundColor = [UIColor whiteColor];
    [_notificationView addSubview:self.contentView];
    [_notificationView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismiss:)]];
    
    return _notificationView;
}

- (UIView *)contentView
{
    if (_contentView) return _contentView;
    
    _contentView = [UIView newAutoLayoutView];
    _contentView.clipsToBounds = YES;
    [_contentView addSubview:self.messageLabel];
    
    return _contentView;
}

- (UILabel *)messageLabel
{
    if (_messageLabel) return _messageLabel;
    
    _messageLabel = [UILabel newAutoLayoutView];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.font = [UIFont defaultFont];
    _messageLabel.textColor = [UIColor blackColor];
    
    return _messageLabel;
}

- (void)addContraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_contentView);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|" views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_contentView]-5-|" views:views]];
    [self.contentView layoutIfNeeded];  // For get content view's frame
    
    [self.messageLabel constraintsEqualHeightWithSuperView];
    [self.messageLabel constraintsCenterYWithView:self.contentView];
    self.labelCenterConstraint = [NSLayoutConstraint constraintCenterXWithItem:self.messageLabel];
}

- (void)updateConstraints
{
    self.labelCenterConstraint.active = !self.messageLabel.isScrollable;
    [super updateConstraints];
}

#pragma mark - Orientation observer
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusBarFrame) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)orientationDidChange
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
    [self setNeedsUpdateConstraints];
    [self.messageLabel scrollIfNeeded];
}

- (void)updateStatusBarFrame
{
    self.hidden = YES;
    self.height = self.isShowing ? 0 : self.statusBarHeight;
    self.notificationView.height = self.statusBarHeight;
}

#pragma mark - Notification message
- (void)showWithMessage:(NSString *)message
{
    self.showing = YES;
    
    self.messageLabel.text = message;
    [self.messageLabel scrollIfNeeded];
    [self setNeedsUpdateConstraints];
    
    NSTimeInterval scrollDuration = self.messageLabel.scrollDuration;
    NSTimeInterval delay = self.messageLabel.isScrollable ? scrollDuration + KLLabelScrollDelay : self.duration;
    [UIView animateWithDefaultDuration:^{
        self.notificationView.top = 0;
        self.frame = CGRectMake(0, self.statusBarHeight, self.width, 0);
    } completion:^(BOOL finished) {
        KLDispatchMainAfter(delay, ^{
            [self dismissAnimated:YES];
        });
    }];
}

- (void)dismissAnimated:(BOOL)animated
{
    if (!animated) {
        [self resetAllSubviews]; return;
    }
    
    [UIView animateWithDefaultDuration:^{
        self.notificationView.top = -self.statusBarHeight;
        self.frame = CGRectMake(0, 0, self.width, self.statusBarHeight);
    } completion:^(BOOL finished) {
        [self resetAllSubviews];
    }];
}

- (void)resetAllSubviews
{
    [self.statusBarWindow.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.statusBarWindow.hidden = YES;
    self.statusBarWindow = nil;
    
    self.showing = NO;
    sharedStatusBar = nil;
}

- (NSTimeInterval)duration
{
    NSTimeInterval duration = self.messageLabel.text.length * 0.06 + 0.5;
    if ([self.messageLabel.text containsUnicodeCharacter]) {
        duration *= 2;  // Chinese or Japanese
    }
    return duration;
}

- (void)tapToDismiss:(UITapGestureRecognizer *)recognizer
{
    [self.class dismiss];
}

@end
