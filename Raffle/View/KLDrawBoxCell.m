//
//  KLDrawBoxCell.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawBoxCell.h"

@implementation KLDrawBoxCell

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
    
    [self.imageView constraintsEqualWithSuperView];
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.layer.cornerRadius = self.width / 2;
    self.imageView.layer.borderWidth = 2.0;
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
}

@end
