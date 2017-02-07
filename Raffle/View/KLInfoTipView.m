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
        self.layer.shadowOpacity = 0.3;
        self.layer.shadowOffset = CGSizeMake(0, -3);
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
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_textLabel]-10-|" views:views]];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    [self.class dismiss];
    return [super hitTest:point withEvent:event];
}

- (void)drawBubbleBox
{
    self.arrowDirection = KLInfoTipViewArrowDirectionDown;
    
}

- (void)updateConstraints
{
    [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                    toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:200].active = YES;
    
    switch (self.arrowDirection) {
        case KLInfoTipViewArrowDirectionUp:
            [self constraintsCenterXWithView:self.sourceView];
            [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                            toItem:self.sourceView attribute:NSLayoutAttributeBottom multiplier:1 constant:0].active = YES;
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
    [sharedTipView setAnimatedHidden:YES completion:^{
        [sharedTipView removeFromSuperview];
        sharedTipView = nil;
    }];
}

@end
