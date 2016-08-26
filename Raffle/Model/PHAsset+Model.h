//
//  PHAsset+Model.h
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Photos/Photos.h>
@import CoreData;

typedef void (^KLAssetBlockType)(UIImage *image, NSDictionary *info);

@interface PHAsset (Model)

@property (nonatomic, assign, getter=isSelected) BOOL selected;

- (void)thumbnailImageProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(KLAssetBlockType)resultHandler;
- (void)originalImageProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(KLAssetBlockType)resultHandler;

@end
