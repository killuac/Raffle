//
//  KLInfoTipView.m
//  Raffle
//
//  Created by Killua Liu on 1/21/17.
//  Copyright © 2017 Syzygy. All rights reserved.
//

#import "KLInfoTipView.h"

typedef NS_ENUM(NSUInteger, KLInfoTipViewArrowDirection) {
    KLInfoTipViewArrowDirectionUp,
    KLInfoTipViewArrowDirectionDown
};

@interface KLInfoTipView ()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *sourceView;
@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) UIView *transparentView;  // For determine info tip view's position

@property (nonatomic, assign) KLInfoTipViewArrowDirection arrowDirection;
@property (nonatomic, strong) NSArray *textLabelConstraints;

@end

@implementation KLInfoTipView

static KLInfoTipView *sharedTipView = nil;
static const CGFloat kInfoTipViewMaxWidth = 220;

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

+ (instancetype)infoTipViewWithText:(NSString *)text
{
    return [[self alloc] initWithText:text];
}

- (instancetype)initWithText:(NSString *)text
{
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:({
            _textLabel = [UILabel newAutoLayoutView];
            _textLabel.text = text;
            _textLabel.font = UIFont.largeFont;
            _textLabel.textColor = UIColor.blackColor;
            _textLabel.numberOfLines = 0;
            _textLabel;
        })];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_textLabel);
        self.textLabelConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_textLabel]-10-|" views:views];
        [NSLayoutConstraint activateConstraints:self.textLabelConstraints];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_textLabel]-10-|" views:views]];
        [self layoutIfNeeded];
    }
    return self;
}

- (void)setSourceView:(UIView *)sourceView
{
    _sourceView = sourceView;
    
    _transparentView = [UIView newAutoLayoutView];
    _transparentView.backgroundColor = UIColor.clearColor;
    [sourceView.superview addSubview:_transparentView];
    
    [NSLayoutConstraint constraintWidthWithItem:_transparentView constant:sourceView.width].active = YES;
    [NSLayoutConstraint constraintHeightWithItem:_transparentView constant:sourceView.height].active = YES;
    [NSLayoutConstraint constraintWithItem:_transparentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                    toItem:sourceView.superview attribute:NSLayoutAttributeTop multiplier:1 constant:sourceView.top].active = YES;
    [NSLayoutConstraint constraintWithItem:_transparentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                    toItem:sourceView.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:sourceView.left].active = YES;
    
    [sourceView.superview layoutIfNeeded];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    [self.class dismiss];
    return [super hitTest:point withEvent:event];
}

- (void)drawBubbleBox
{
    CGFloat radius = 8.0; CGFloat arrowHeight = 10;
    CGFloat arrowCenterX = self.transparentView.centerX - self.left;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    if (self.arrowDirection == KLInfoTipViewArrowDirectionUp) {
        [bezierPath moveToPoint:CGPointMake(radius, arrowHeight)];
        [bezierPath addLineToPoint:CGPointMake(arrowCenterX - 8, arrowHeight)];
        [bezierPath addLineToPoint:CGPointMake(arrowCenterX, 0)];
        [bezierPath addLineToPoint:CGPointMake(arrowCenterX + 8, arrowHeight)];
        [bezierPath addLineToPoint:CGPointMake(self.width - radius, arrowHeight)];
        [bezierPath addArcWithCenter:CGPointMake(self.width - radius, radius + arrowHeight) radius:radius startAngle:3/2 * M_PI endAngle:2 * M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(self.width, self.height - radius)];
        [bezierPath addArcWithCenter:CGPointMake(self.width - radius, self.height - radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(radius, self.height)];
        [bezierPath addArcWithCenter:CGPointMake(radius, self.height - radius) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(0, radius + arrowHeight)];
        [bezierPath addArcWithCenter:CGPointMake(radius, radius + arrowHeight) radius:radius startAngle:M_PI endAngle:2 * M_PI clockwise:YES];
    } else {
        [bezierPath moveToPoint:CGPointMake(radius, 0)];
        [bezierPath addLineToPoint:CGPointMake(self.width - radius, 0)];
        [bezierPath addArcWithCenter:CGPointMake(self.width - radius, radius) radius:radius startAngle:3/2 * M_PI endAngle:2 * M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(self.width, self.height - radius - arrowHeight)];
        [bezierPath addArcWithCenter:CGPointMake(self.width - radius, self.height - radius - arrowHeight) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(arrowCenterX + 8, self.height - arrowHeight)];
        [bezierPath addLineToPoint:CGPointMake(arrowCenterX, self.height)];
        [bezierPath addLineToPoint:CGPointMake(arrowCenterX - 8, self.height - arrowHeight)];
        [bezierPath addLineToPoint:CGPointMake(radius, self.height - arrowHeight)];
        [bezierPath addArcWithCenter:CGPointMake(radius, self.height - radius - arrowHeight) radius:radius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(0, radius)];
        [bezierPath addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI endAngle:2 * M_PI clockwise:YES];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_textLabel);
        [NSLayoutConstraint deactivateConstraints:self.textLabelConstraints];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_textLabel]-20-|" options:0 metrics:nil views:views]];
    }
    [bezierPath closePath];
    
    CAShapeLayer *shaperLayer = (id)self.layer;
    shaperLayer.path = bezierPath.CGPath;
    shaperLayer.fillColor = UIColor.whiteColor.CGColor;
    shaperLayer.shadowColor = UIColor.blackColor.CGColor;
    shaperLayer.shadowRadius = 5.0;
    shaperLayer.shadowOpacity = 0.4;
    shaperLayer.shadowOffset = CGSizeMake(0, (self.arrowDirection == KLInfoTipViewArrowDirectionUp) ? 3 : -3);
    shaperLayer.shadowPath = bezierPath.CGPath;
}

- (void)addConstraints
{
    self.arrowDirection = (self.sourceView.bottom + self.height < self.targetView.bottom) ? KLInfoTipViewArrowDirectionUp : KLInfoTipViewArrowDirectionDown;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(self);
    NSDictionary *metrics = @{ @"maxWidth": @(kInfoTipViewMaxWidth) };
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0@999)-[self(<=maxWidth)]-(>=0@998)-|" options:0 metrics:metrics views:views]];
    
    switch (self.arrowDirection) {
        case KLInfoTipViewArrowDirectionUp:
            [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                            toItem:self.transparentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
            break;
            
        case KLInfoTipViewArrowDirectionDown:
            [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                            toItem:self.transparentView attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
            break;
    }
    
    NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                           toItem:self.transparentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    centerConstraint.active = (self.sourceView.centerX >= self.width / 2);
    
    [self.superview layoutIfNeeded];
}

+ (void)showInfoTipWithText:(NSString *)text sourceView:(UIView *)sourceView targetView:(UIView *)targetView
{
    sharedTipView = [KLInfoTipView infoTipViewWithText:text];
    sharedTipView.sourceView = sourceView;
    sharedTipView.targetView = targetView;
    [targetView addSubview:sharedTipView];
    
    [sharedTipView addConstraints];
    [sharedTipView drawBubbleBox];
    [sharedTipView setAnimatedHidden:NO completion:nil];
}

+ (void)dismiss
{
    [sharedTipView.transparentView removeFromSuperview];
    [sharedTipView setAnimatedHidden:YES completion:^{
        [sharedTipView removeFromSuperview];
        sharedTipView = nil;
    }];
}

@end
