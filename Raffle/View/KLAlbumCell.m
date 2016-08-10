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
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self.contentView addSubview:_imageView];
    
    _checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_checkmark"]];
    [self.contentView addSubview:_checkmark];
}

- (void)updateConstraints
{
    [self.imageView constraintsEqualWithSuperView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_checkmark);
    NSDictionary *metrics = @{ @"margin": @(5) };
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_checkMark]-margin-|" options:0 metrics:metrics views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_checkMark]-margin-|" options:0 metrics:metrics views:views]];
    
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.checkmark.hidden = !selected;
    self.imageView.alpha = selected ? 0.9 : 1.0;
}

- (void)configWithAsset:(PHAsset *)asset
{
    [asset thumbnailImageProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
//      TODO: Add load image progress
    } resultHandler:^(UIImage *image, NSDictionary *info) {
        self.imageView.image = image;
        [self setNeedsLayout];
    }];
}

@end
