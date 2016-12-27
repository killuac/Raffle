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
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = IS_PAD ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView;
    })];
    
    [self.imageView addSubview:({
        _overlayView = [UIView newAutoLayoutView];
        _overlayView.hidden = YES;
        _overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        _overlayView;
    })];
    
    [self.imageView addSubview:({
        _checkmark = [UIImageView newAutoLayoutView];
        _checkmark.hidden = YES;
        _checkmark.image = [UIImage imageNamed:@"icon_checkmark"];
        _checkmark;
    })];
    
    [self.overlayView constraintsEqualWithSuperView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_checkmark);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_checkmark]-5-|" views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_checkmark]-5-|" views:views]];
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
//      TODO: Add load image progress
    } resultHandler:^(UIImage *image, NSDictionary *info) {
        self.userInteractionEnabled = YES;
        self.imageView.image = image;
        self.imageView.frame = IS_PAD ? AVMakeRectWithAspectRatioInsideRect(image.size, self.imageView.frame) : self.imageView.frame;
        self.selected = asset.isSelected;
        [self.imageView setNeedsLayout];
    }];
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
