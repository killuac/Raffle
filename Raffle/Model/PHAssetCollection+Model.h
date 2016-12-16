//
//  PHAssetCollection+Model.h
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Photos/Photos.h>
#import "PHAsset+Model.h"

@interface PHAssetCollection (Model)

@property (nonatomic, readonly) PHFetchResult *fetchResult;
@property (nonatomic, readonly) NSUInteger assetCount;
@property (nonatomic, readonly) NSArray<PHAsset *> *assets;

@property (nonatomic, assign) CGPoint contentOffset;  // Remember scrolled content offset

- (void)fetchAssets:(KLVoidBlockType)completion;
- (void)updateWithAssetCollection:(PHAssetCollection *)collection;

- (void)posterImage:(KLAssetBlockType)resultHandler;

@end
