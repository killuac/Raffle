//
//  KLPhotoLibrary.h
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHAssetCollection+Model.h"

@interface KLPhotoLibrary : NSObject

@property (nonatomic, strong, readonly) NSArray<PHAssetCollection *> *assetCollections;
@property (nonatomic, strong, readonly) NSArray<NSString *> *assetCollectionTitles;
@property (nonatomic, strong, readonly) NSMutableArray *selectedAssets;

@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, assign, readonly) BOOL isPageScrollEnabled;
@property (nonatomic, assign, readonly) NSUInteger assetCollectionCount;

- (void)checkAuthorization:(KLVoidBlockType)handler;
- (PHAssetCollection *)assetCollectionAtIndex:(NSUInteger)index;

- (void)addAsset:(PHAsset *)asset;
- (void)removeAsset:(PHAsset *)asset;

@end
