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
@property (nonatomic, strong) NSMutableArray *selectedAssets;

@end

@implementation KLDrawBoxDataController

- (instancetype)initWithModel:(KLDrawBoxModel *)model
{
    if (self = [self init]) {
        _drawBox = model;
        _allAssets = [NSMutableArray arrayWithArray:_drawBox.assets];
        _selectedAssets = [NSMutableArray array];
    }
    return self;
}

- (NSUInteger)itemCount
{
    return self.allAssets.count;
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

// New insert entry at front of the old entry
- (void)addPhotos:(NSArray<PHAsset *> *)assets
{
    __block NSUInteger assetCount = 0;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self.drawBox.assets containsObject:asset]) {
                KLPhotoModel *photoModel = [KLPhotoModel MR_createEntityInContext:localContext];
                photoModel.assetLocalIdentifier = asset.localIdentifier;
                photoModel.drawBox = [self.drawBox MR_inContext:localContext];
                
                [self.allAssets addObject:asset];
                assetCount++;
            }
        }];
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSUInteger i = 0; i < assetCount; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        [self didChangeAtIndexPaths:indexPaths forChangeType:KLDataChangeTypeInsert];
    }];
}

- (PHAsset *)randomAnAsset
{
    NSUInteger index = KLRandomNumber(0, self.itemCount);
    return [self objectAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

#pragma mark - Assets selection
- (NSUInteger)selectedAssetCount
{
    return self.selectedAssets.count;
}

- (void)selectAssetAtIndexPath:(NSIndexPath *)indexPath
{
    [self willChangeValueForSelectedAssets];
    PHAsset *asset = [self objectAtIndexPath:indexPath];
    asset.selected = YES;
    if (![self.selectedAssets containsObject:asset]) {
        [self.selectedAssets addObject:asset];
    }
    [self didChangeValueForSelectedAssets];
}

- (void)deselectAssetAtIndexPath:(NSIndexPath *)indexPath
{
    [self willChangeValueForSelectedAssets];
    PHAsset *asset = [self objectAtIndexPath:indexPath];
    asset.selected = NO;
    [self.selectedAssets removeObject:asset];
    [self didChangeValueForSelectedAssets];
}

- (void)clearSelection
{
    [self willChangeValueForSelectedAssets];
    [self.selectedAssets setValue:@(NO) forKey:@"selected"];
    [self.selectedAssets removeAllObjects];
    [self didChangeValueForSelectedAssets];
}

- (void)deleteSelectedAssets
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [self.selectedAssets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            NSUInteger index = [self.drawBox.photos indexOfObjectPassingTest:^BOOL(KLPhotoModel * _Nonnull photoModel, NSUInteger idx, BOOL * _Nonnull stop) {
                return [photoModel.assetLocalIdentifier isEqualToString:asset.localIdentifier];
            }];
            if (index != NSNotFound) {
                KLPhotoModel *photoModel = self.drawBox.photos[index];
                [photoModel MR_deleteEntity];
                [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
            }
        }];
        
        // If all photos deleted in draw box, also need delete draw box.
        if (self.selectedAssetCount == self.itemCount) {
            [self.drawBox MR_deleteEntity];
        }
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        [self didChangeAtIndexPaths:indexPaths forChangeType:KLDataChangeTypeDelete];
    }];
}

- (void)willChangeValueForSelectedAssets
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(selectedAssets))];
}

- (void)didChangeValueForSelectedAssets
{
    [self didChangeValueForKey:NSStringFromSelector(@selector(selectedAssets))];
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
    [self willChangeValueForKey:NSStringFromSelector(@selector(allAssets))];
    // TODO: Remove assets that don't exist in photo library
    [self.allAssets removeAllObjects];
    [self.allAssets addObjectsFromArray:self.drawBox.assets];
    [self didChangeValueForKey:NSStringFromSelector(@selector(allAssets))];
}

@end
