//
//  KLDrawBoxCell.h
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAsset+Model.h"

@interface KLDrawBoxCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;

- (void)configWithAsset:(PHAsset *)asset;

@end
