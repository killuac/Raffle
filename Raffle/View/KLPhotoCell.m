//
//  KLPhotoCell.m
//  Raffle
//
//  Created by Killua Liu on 3/18/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLPhotoCell.h"

@interface KLPhotoCell ()

@property (nonatomic, strong) UIImageView *checkmark;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) KLPieProgressView *progressView;

@end

@implementation KLPhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews
{
    [self.contentView addSubview:({
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = IS_PAD ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
        if (IS_PAD) {
            _imageView.layer.borderWidth = 5;
            _imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        _imageView;
    })];
    
    [self.imageView addSubview:({
        _overlayView = [UIView newAutoLayoutView];
        _overlayView.hidden = YES;
        _overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        _overlayView;
    })];
    [self.overlayView constraintsEqualWithSuperView];
    
    [self.imageView addSubview:({
        _checkmark = [UIImageView newAutoLayoutView];
        _checkmark.hidden = YES;
        _checkmark.image = [UIImage imageNamed:@"icon_checkmark"];
        _checkmark;
    })];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_checkmark);
    NSDictionary *metrics = @{ @"margin": (IS_PAD ? @10 : @5) };
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_checkmark]-margin-|" options:0 metrics:metrics views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_checkmark]-margin-|" options:0 metrics:metrics views:views]];
    
    [self.contentView addSubview:({
        _progressView = [KLPieProgressView newAutoLayoutView];
        _progressView.hidden = YES;
        _progressView;
    })];
    [self.progressView constraintsCenterInSuperview];
}

- (void)prepareForReuse
{
    self.selected = self.highlighted = NO;
    [self removeGestureRecognizer:self.longPress];
}

- (void)setLongPress:(UILongPressGestureRecognizer *)longPress
{
    _longPress = longPress;
    [self addGestureRecognizer:longPress];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.contentView.alpha = highlighted ? 0.5 : 1.0;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.contentView.alpha = 1.0;
    self.overlayView.hidden = !selected;
    self.checkmark.hidden = !selected;
}

- (void)configWithAsset:(PHAsset *)asset
{
    self.userInteractionEnabled = NO;
    [asset thumbnailImageProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        KLDispatchMainAsync(^{
            [self.progressView setProgress:progress animated:YES];
        });
    } resultHandler:^(UIImage *image, NSDictionary *info) {
        [self.progressView removeFromSuperview];
        self.userInteractionEnabled = YES;
        self.imageView.image = image;
        self.imageView.frame = IS_PAD ? AVMakeRectWithAspectRatioInsideRect(image.size, self.imageView.frame) : self.imageView.frame;
        self.selected = asset.isSelected;
        [self.imageView setNeedsLayout];
    }];
}

- (void)test:(NSNumber *)progress
{
    [self.progressView setProgress:progress.floatValue animated:YES];
}

#pragma mark - Animation
- (void)animateSpringScale
{
    [UIView animateWithDefaultDuration:^{
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateSpringWithDefaultDuration:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }];
}

@end
