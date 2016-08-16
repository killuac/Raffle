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
@property (nonatomic, strong) UIImage *originalImage;

@end

@implementation KLAlbumCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)addSubviews
{
    _imageView = [UIImageView newAutoLayoutView];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self.contentView addSubview:_imageView];
    
    _checkmark = [UIImageView newAutoLayoutView];
    _checkmark.image = [UIImage imageNamed:@"icon_checkmark"];
    _checkmark.hidden = YES;
    [self.contentView addSubview:_checkmark];
}

- (void)updateConstraints
{
    [self.imageView constraintsEqualWithSuperView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_checkmark);
    NSDictionary *metrics = @{ @"margin": @(5) };
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_checkmark]-margin-|" options:0 metrics:metrics views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_checkmark]-margin-|" options:0 metrics:metrics views:views]];
    
    [super updateConstraints];
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
    self.imageView.image = self.isSelected ? [self.originalImage brightenWithAlpha:0.5] : self.originalImage;
}

- (void)configWithAsset:(PHAsset *)asset
{
    [asset thumbnailImageProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
//      TODO: Add load image progress
    } resultHandler:^(UIImage *image, NSDictionary *info) {
        self.originalImage = image;
        self.imageView.image = image;
        self.selected = asset.isSelected;
        [self setNeedsLayout];
    }];
}

@end
