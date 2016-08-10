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

@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, assign, readonly) NSUInteger assetCount;
@property (nonatomic, strong, readonly) NSArray<PHAsset *> *assets;

- (void)fetchAssets;
- (void)posterImage:(KLAssetBlockType)resultHandler;

@end
