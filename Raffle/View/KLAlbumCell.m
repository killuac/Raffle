//
//  KLAlbumCell.m
//  Raffle
//
//  Created by Killua Liu on 3/18/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLAlbumCell.h"

@interface KLAlbumCell ()

@property (nonatomic, strong) UIImageView *checkmark;
@property (nonatomic, strong) UIView *overlayView;

@end

@implementation KLAlbumCell

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
        _imageView = [UIImageView newAutoLayoutView];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView;
    })];
    
    [self.imageView addSubview:({
        _overlayView = [UIView newAutoLayoutView];
        _overlayView.hidden = YES;
        _overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        _overlayView;
    })];
    
    [self.contentView addSubview:({
        _checkmark = [UIImageView newAutoLayoutView];
        _checkmark.image = [UIImage imageNamed:@"icon_checkmark"];
        _checkmark.hidden = YES;
        _checkmark;
    })];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_checkmark);
    [self.imageView constraintsEqualWithSuperView];
    [self.overlayView constraintsEqualWithSuperView];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_checkmark]-5-|" views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_checkmark]-5-|" views:views]];
}

- (void)prepareForReuse
{
    self.selected = self.highlighted = NO;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.imageView.alpha = highlighted ? 0.5 : 1.0;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.checkmark.hidden = !selected;
    self.imageView.alpha = 1.0;
    self.overlayView.hidden = !selected;
}

- (void)configWithAsset:(PHAsset *)asset
{
    [asset thumbnailImageProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
//      TODO: Add load image progress
    } resultHandler:^(UIImage *image, NSDictionary *info) {
        self.imageView.image = image;
        self.selected = asset.isSelected;
        [self setNeedsLayout];
    }];
}

#pragma mark - Animation
- (void)animateSpringScale
{
    [UIView animateWithDefaultDuration:^{
        self.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateSpringWithDefaultDuration:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }];
}

@end
