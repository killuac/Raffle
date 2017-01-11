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
@property (nonatomic, readonly) BOOL isAttendeeMode;
@property (nonatomic, readonly) BOOL isReloadButtonHidden;
@property (nonatomic, readonly) BOOL isShakeEnabled;
@property (nonatomic, readonly) BOOL hasCustomWallpaper;

@property (nonatomic, readonly) NSUInteger remainingAssetCount;
@property (nonatomic, readonly) NSUInteger selectedAssetCount;
@property (nonatomic, readonly) NSString *wallpaperFilePath;

- (void)switchDrawMode;
- (void)reloadAllAssets;
- (PHAsset *)randomAnAsset;

- (void)changeWallpaperWithImageName:(NSString *)imageName;
- (void)changeWallpaperWithAsset:(PHAsset *)asset completion:(KLVoidBlockType)completion;

- (void)addPhotos:(NSArray<PHAsset *> *)assets completion:(KLVoidBlockType)complition;
- (void)deleteSelectedAssets;

- (void)selectAssetAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectAssetAtIndexPath:(NSIndexPath *)indexPath;
- (void)clearSelection;

@end
