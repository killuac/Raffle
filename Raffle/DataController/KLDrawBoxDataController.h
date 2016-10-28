//
//  KLDrawBoxDataController.h
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDataController.h"
#import "KLDrawBoxModel.h"

@interface KLDrawBoxDataController : KLDataController

@property (nonatomic, assign) NSUInteger pageIndex;
@property (nonatomic, assign, readonly) BOOL isAttendeeMode;
@property (nonatomic, assign, readonly) BOOL isReloadButtonHidden;
@property (nonatomic, assign, readonly) BOOL isShakeEnabled;

@property (nonatomic, assign, readonly) NSUInteger remainingAssetCount;
@property (nonatomic, assign, readonly) NSUInteger selectedAssetCount;

- (void)switchDrawMode;
- (void)reloadAllAssets;
- (PHAsset *)randomAnAsset;

- (void)addPhotos:(NSArray<PHAsset *> *)assets completion:(KLVoidBlockType)complition;
- (void)deleteSelectedAssets;

- (void)selectAssetAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectAssetAtIndexPath:(NSIndexPath *)indexPath;
- (void)clearSelection;

@end
