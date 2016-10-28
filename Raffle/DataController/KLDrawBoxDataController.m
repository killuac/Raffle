//
//  KLDrawBoxDataController.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawBoxDataController.h"

@interface KLDrawBoxDataController () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) KLDrawBoxModel *drawBox;
@property (nonatomic, strong) NSMutableArray *allAssets;
@property (nonatomic, strong) NSMutableArray *remainingAssets;
@property (nonatomic, strong) NSMutableArray *selectedAssets;

@end

@implementation KLDrawBoxDataController

- (instancetype)initWithModel:(KLDrawBoxModel *)model
{
    if (self = [self init]) {
        _drawBox = model;
        _allAssets = [NSMutableArray arrayWithArray:_drawBox.assets];
        _remainingAssets = [NSMutableArray arrayWithArray:_drawBox.assets];
        _selectedAssets = [NSMutableArray array];
    }
    return self;
}

- (NSUInteger)itemCount
{
    return self.allAssets.count;
}

- (NSUInteger)remainingAssetCount
{
    return self.remainingAssets.count;
}

- (BOOL)isAttendeeMode
{
    return (self.drawBox.drawMode == KLDrawModeAttendee);
}

- (BOOL)isReloadButtonHidden
{
    return (!self.isAttendeeMode || self.itemCount == self.drawBox.assets.count);
}

- (BOOL)isShakeEnabled
{
    return self.itemCount > 0;
}

- (PHAsset *)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return self.allAssets[indexPath.item];
}

- (void)switchDrawMode
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        self.drawBox.drawMode = !self.drawBox.drawMode;
    }];
}

- (void)reloadAllAssets
{
    [self.remainingAssets removeAllObjects];
    [self.remainingAssets addObjectsFromArray:self.allAssets];
}

- (PHAsset *)randomAnAsset
{
    NSUInteger index = KLRandomNumber(0, self.remainingAssetCount);
    return self.remainingAssets[index];
}

#pragma mark - Update assets
// New insert entry at front of the old entry
- (void)addPhotos:(NSArray<PHAsset *> *)assets completion:(KLVoidBlockType)complition
{
    __block NSUInteger assetCount = 0;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self.drawBox.assets containsObject:asset]) {
                KLPhotoModel *photoModel = [KLPhotoModel MR_createEntityInContext:localContext];
                photoModel.assetLocalIdentifier = asset.localIdentifier;
                photoModel.drawBox = [self.drawBox MR_inContext:localContext];
                
                [self.allAssets addObject:asset];
                [self.remainingAssets addObject:asset];
                assetCount++;
            }
        }];
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSUInteger i = 0; i < assetCount; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        [self didChangeAtIndexPaths:indexPaths forChangeType:KLDataChangeTypeInsert];
        
        if (complition) complition();
    }];
}

- (void)deleteSelectedAssets
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    [self.allAssets removeObjectsInArray:self.selectedAssets];
    [self.remainingAssets removeObjectsInArray:self.selectedAssets];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [self.selectedAssets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            NSUInteger index = [self.drawBox.assets indexOfObject:asset];
            if (index != NSNotFound) {
                KLPhotoModel *photoModel = self.drawBox.photos[index];
                [photoModel MR_deleteEntityInContext:localContext];
                [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
            }
        }];
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        [self clearSelection];
        [self didChangeAtIndexPaths:indexPaths forChangeType:KLDataChangeTypeDelete];
    }];
}

#pragma mark - Select assets
- (NSUInteger)selectedAssetCount
{
    return self.selectedAssets.count;
}

- (void)selectAssetAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = [self objectAtIndexPath:indexPath];
    asset.selected = YES;
    if (![self.selectedAssets containsObject:asset]) {
        [self.selectedAssets addObject:asset];
    }
    [self didChangeSelection];
}

- (void)deselectAssetAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = [self objectAtIndexPath:indexPath];
    asset.selected = NO;
    [self.selectedAssets removeObject:asset];
    [self didChangeSelection];
}

- (void)clearSelection
{
    [self.selectedAssets setValue:@(NO) forKey:@"selected"];
    [self.selectedAssets removeAllObjects];
    [self didChangeSelection];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)addObservers
{
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // TODO: Remove assets that don't exist in photo library
    // TODO: Also need remove retaining assets that don't exist
    [self.allAssets removeAllObjects];
    [self.allAssets addObjectsFromArray:self.drawBox.assets];
//    [self didChangeAtIndexPaths:@[] forChangeType:KLDataChangeTypeDelete];
}

@end
