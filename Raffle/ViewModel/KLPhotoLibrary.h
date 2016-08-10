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

@property (nonatomic, assign) NSUInteger selectedAssetCollectionIndex;
@property (nonatomic, strong, readonly) PHAssetCollection *selectedAssetCollection;
@property (nonatomic, assign, readonly) NSUInteger selectedCollectionAssetCount;

@property (nonatomic, assign, readonly) BOOL isPageScrollEnabled;
@property (nonatomic, assign, readonly) NSUInteger assetCollectionCount;

- (void)checkAuthorization:(KLVoidBlockType)handler;
- (PHAsset *)assetAtIndex:(NSUInteger)index;

@end
