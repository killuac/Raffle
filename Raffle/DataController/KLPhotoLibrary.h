//
//  KLPhotoLibrary.h
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDataController.h"
#import "PHAssetCollection+Model.h"

@interface KLPhotoLibrary : KLDataController

@property (nonatomic, readonly) NSArray<PHAssetCollection *> *assetCollections;
@property (nonatomic, readonly) NSArray<PHAsset *> *selectedAssets;

- (PHAssetCollection *)assetCollectionAtIndex:(NSUInteger)index;

- (void)selectAsset:(PHAsset *)asset;
- (void)deselectAsset:(PHAsset *)asset;

@end
