//
//  KLPieProgressView.m
//  Raffle
//
//  Created by Killua Liu on 1/8/17.
//  Copyright © 2017 Syzygy. All rights reserved.
//

#import "KLPieProgressView.h"
#import "KLWeakTarget.h"

@interface KLPieProgressView ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, assign) CGFloat circleRadius;
@property (nonatomic, assign) CGPoint circleCenter;
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CFTimeInterval animationStartTime;
@property (nonatomic, assign) CGFloat animationFromValue;
@property (nonatomic, assign) CGFloat animationToValue;

@end

@implementation KLPieProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _circleRadius = 20;
        _circleCenter = CGPointMake(_circleRadius, _circleRadius);
        
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = self.circleRadius;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.fillColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:_circleLayer];
    }
    
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(self.circleRadius * 2, self.circleRadius * 2);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.size = self.intrinsicContentSize;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    _animationFromValue = self.progress;
    _animationToValue = progress;
    
    if (animated) {
        _animationStartTime = CACurrentMediaTime();
        self.displayLink.paused = NO;
    } else {
        self.progress = progress;
        self.displayLink.paused = YES;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = -M_PI_2 + 2 * M_PI * self.progress;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:self.circleCenter];
    [bezierPath addArcWithCenter:self.circleCenter radius:self.circleRadius-2 startAngle:startAngle endAngle:endAngle clockwise:YES];
    [bezierPath closePath];
    
    self.circleLayer.path = bezierPath.CGPath;
}

- (CADisplayLink *)displayLink
{
    if (_displayLink) return _displayLink;
    
    KLWeakTarget *weakTarget = [KLWeakTarget weakTargetWithTarget:self selector:@selector(animateProgress:)];
    _displayLink = [CADisplayLink displayLinkWithTarget:weakTarget selector:@selector(actionDidFire:)];
    [_displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    return _displayLink;
}

- (void)animateProgress:(CADisplayLink *)displayLink
{
    NSTimeInterval animationDuration = 0.3;
    CGFloat dt = (displayLink.timestamp - self.animationStartTime) / animationDuration;
    if (dt < 1.0) {
        self.progress = self.animationFromValue + dt * (self.animationToValue - self.animationFromValue);
        [self setNeedsDisplay];
    } else {    // Avoid concurrency issue
        [self setProgress:self.animationToValue animated:NO];
    }
}

- (void)dealloc
{
    if (_displayLink) {
        [self.displayLink invalidate];
    }
}

@end
