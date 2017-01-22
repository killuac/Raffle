//
//  KLInfoTipView.m
//  Raffle
//
//  Created by Killua Liu on 1/21/17.
//  Copyright © 2017 Syzygy. All rights reserved.
//

#import "KLInfoTipView.h"

@interface KLInfoTipView ()

@property (nonatomic, strong) NSString *text;

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
        _text = text;
        
        [self addSubview:({
            _textLabel = [UILabel newAutoLayoutView];
            _textLabel.font = UIFont.boldLargeFont;
            _textLabel.textColor = UIColor.blackColor;
            _textLabel.numberOfLines = 0;
            _textLabel;
        })];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_textLabel);
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[_textLabel]-16-|" views:views]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[_textLabel]-16-|" views:views]];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(200, [self.textLabel.text heightWithFont:self.textLabel.font]);
}

+ (void)showInfoTipWithText:(NSString *)text sourceView:(UIView *)sourceView targetView:(UIView *)targetView
{
    KLInfoTipView *tipView = [KLInfoTipView infoTipViewWithText:text];
    
    sharedTipView = tipView;
}

+ (void)dismiss
{
    [sharedTipView setAnimatedHidden:YES completion:^{
        [sharedTipView removeFromSuperview];
        sharedTipView = nil;
    }];
}

@end
