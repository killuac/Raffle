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
    KLInfoTipViewArrowDirectionDown,
    KLInfoTipViewArrowDirectionLeft,
    KLInfoTipViewArrowDirectionRight
};

@interface KLInfoTipView ()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *sourceView;
@property (nonatomic, strong) UIView *transparentView;  // For determine info tip view's position

@property (nonatomic, assign) KLInfoTipViewArrowDirection arrowDirection;

@end

@implementation KLInfoTipView

static KLInfoTipView *sharedTipView = nil;

+ (instancetype)infoTipViewWithText:(NSString *)text
{
    return [[self alloc] initWithText:text];
}

- (instancetype)initWithText:(NSString *)text
{
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = UIColor.whiteColor;
        self.layer.shadowColor = UIColor.blackColor.CGColor;
        self.layer.shadowOpacity = 0.4;
        self.layer.shadowOffset = CGSizeMake(0, 3);
        self.layer.shadowRadius = 5.0;
        
        [self addSubview:({
            _textLabel = [UILabel newAutoLayoutView];
            _textLabel.text = text;
            _textLabel.font = UIFont.largeFont;
            _textLabel.textColor = UIColor.blackColor;
            _textLabel.numberOfLines = 0;
            _textLabel;
        })];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_textLabel);
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_textLabel]-10-|" views:views]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[_textLabel]-16-|" views:views]];
    }
    return self;
}

- (void)setSourceView:(UIView *)sourceView
{
    _sourceView = sourceView;
    
    _transparentView = [UIView newAutoLayoutView];
    _transparentView.backgroundColor = UIColor.clearColor;
    [sourceView.superview addSubview:_transparentView];
    
    [self.transparentView constraintsCenterXWithView:sourceView];
    [NSLayoutConstraint constraintWidthWithItem:_transparentView constant:sourceView.width].active = YES;
    [NSLayoutConstraint constraintHeightWithItem:_transparentView constant:sourceView.height].active = YES;
    [NSLayoutConstraint constraintWithItem:_transparentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                    toItem:sourceView.superview attribute:NSLayoutAttributeTop multiplier:1 constant:sourceView.top].active = YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    [self.class dismiss];
    return [super hitTest:point withEvent:event];
}

- (void)drawBubbleBox
{
    self.arrowDirection = KLInfoTipViewArrowDirectionUp;
    
}

- (void)updateConstraints
{
    NSLayoutConstraint *leadingConstraint, *trailingConstraint;
    [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                    toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:240].active = YES;
    
    switch (self.arrowDirection) {
        case KLInfoTipViewArrowDirectionUp:
            [self constraintsCenterXWithView:self.transparentView];
            [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                            toItem:self.transparentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
            leadingConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual
                                            toItem:self.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
            trailingConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationGreaterThanOrEqual
                                            toItem:self.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
            leadingConstraint.priority = trailingConstraint.priority = 999;
            leadingConstraint.active = trailingConstraint.active = YES;
            break;
            
        case KLInfoTipViewArrowDirectionDown:
            [self constraintsCenterXWithView:self.sourceView];
            [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                            toItem:self.sourceView attribute:NSLayoutAttributeTop multiplier:1 constant:0].active = YES;
            break;
            
        case KLInfoTipViewArrowDirectionLeft:
            [self constraintsCenterYWithView:self.sourceView];
            [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual
                                            toItem:self.sourceView attribute:NSLayoutAttributeRight multiplier:1 constant:0].active = YES;
            break;
            
        case KLInfoTipViewArrowDirectionRight:
            [self constraintsCenterYWithView:self.sourceView];
            [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual
                                            toItem:self.sourceView attribute:NSLayoutAttributeLeft multiplier:1 constant:0].active = YES;
            break;
    }
    
    [super updateConstraints];
}

+ (void)showInfoTipWithText:(NSString *)text sourceView:(UIView *)sourceView targetView:(UIView *)targetView
{
    sharedTipView = [KLInfoTipView infoTipViewWithText:text];
    sharedTipView.sourceView = sourceView;
    [targetView addSubview:sharedTipView];
    
    [sharedTipView drawBubbleBox];
    [sharedTipView setNeedsUpdateConstraints];
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
