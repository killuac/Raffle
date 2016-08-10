//
//  KLDrawPoolCell.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawPoolCell.h"

@implementation KLDrawPoolCell

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
    self.contentView.layer.cornerRadius = self.width / 2;
//    [self.imageView setCornerRadius:self.width / 2];
}

@end
