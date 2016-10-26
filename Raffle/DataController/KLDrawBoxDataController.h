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
@property (nonatomic, assign, readonly) NSUInteger selectedAssetCount;

- (void)switchDrawMode;
- (void)addPhotos:(NSArray<PHAsset *> *)assets;
- (void)selectAssetAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectAssetAtIndexPath:(NSIndexPath *)indexPath;
- (void)clearSelection;
- (void)deleteSelectedAssets;

- (PHAsset *)randomAnAsset;

@end
