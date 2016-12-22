//
//  KLAlbumCell.h
//  Raffle
//
//  Created by Killua Liu on 3/18/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAsset+Model.h"

@interface KLAlbumCell : UICollectionViewCell

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

- (void)configWithAsset:(PHAsset *)asset;

@end
