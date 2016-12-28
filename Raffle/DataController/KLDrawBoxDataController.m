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
        
        [self addObservers];
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
        self.drawBox.drawMode = (self.drawBox.drawMode == KLDrawModeAttendee) ? KLDrawModePrize : KLDrawModeAttendee;
    }];
}

- (void)reloadAllAssets
{
    [self willChangeValueForRemainingAssetCount];
    [self.remainingAssets removeAllObjects];
    [self.remainingAssets addObjectsFromArray:self.allAssets];
    [self didChangeValueForRemainingAssetCount];
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
    NSUInteger oldCount = self.remainingAssets.count;
    [self willChangeValueForRemainingAssetCount];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        id localDrawBox = [self.drawBox MR_inContext:localContext];
        [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self.drawBox.assets containsObject:asset]) {
                KLPhotoModel *photoModel = [KLPhotoModel MR_createEntityInContext:localContext];
                photoModel.assetLocalIdentifier = asset.localIdentifier;
                photoModel.drawBox = localDrawBox;
                
                [self.allAssets addObject:asset];
                [self.remainingAssets addObject:asset];
            }
        }];
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        [self didChangeValueForRemainingAssetCount];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSUInteger i = oldCount; i < self.remainingAssets.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        [self didChangeAtIndexPaths:indexPaths forChangeType:KLDataChangeTypeInsert];
        
        if (complition) complition();
    }];
}

- (void)deleteSelectedAssets
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    [self.selectedAssets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger index = [self.remainingAssets indexOfObject:asset];
        if (index != NSNotFound) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }
    }];
    
    [self willChangeValueForRemainingAssetCount];
    [self.allAssets removeObjectsInArray:self.selectedAssets];
    [self.remainingAssets removeObjectsInArray:self.selectedAssets];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [self.selectedAssets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            NSUInteger index = [self.drawBox.photos indexOfObjectPassingTest:^BOOL(KLPhotoModel * _Nonnull photo, NSUInteger idx, BOOL * _Nonnull stop) {
                return [photo.assetLocalIdentifier isEqualToString:asset.localIdentifier];
            }];
            if (index != NSNotFound) {
                KLPhotoModel *photoModel = self.drawBox.photos[index];
                [photoModel MR_deleteEntityInContext:localContext];
            }
        }];
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        [self clearSelection];
        [self didChangeAtIndexPaths:indexPaths forChangeType:KLDataChangeTypeDelete];
        [self didChangeValueForRemainingAssetCount];
    }];
}

- (void)willChangeValueForRemainingAssetCount
{
    KLDispatchMainAsync(^{
        [self willChangeValueForKey:NSStringFromSelector(@selector(remainingAssetCount))];
    });
}

- (void)didChangeValueForRemainingAssetCount
{
    KLDispatchMainAsync(^{
        [self didChangeValueForKey:NSStringFromSelector(@selector(remainingAssetCount))];
    });
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
    [self.allAssets removeAllObjects];
    [self.allAssets addObjectsFromArray:self.drawBox.assets];
    
    NSMutableSet *remainingAssetSet = [NSMutableSet setWithArray:self.remainingAssets];
    [remainingAssetSet intersectSet:[NSSet setWithArray:self.allAssets]];
    [self.remainingAssets removeAllObjects];
    [self.remainingAssets addObjectsFromArray:remainingAssetSet.allObjects];
    
    NSMutableSet *selectedAssetSet = [NSMutableSet setWithArray:self.selectedAssets];
    [selectedAssetSet intersectSet:[NSSet setWithArray:self.allAssets]];
    [self.selectedAssets removeAllObjects];
    [self.selectedAssets addObjectsFromArray:selectedAssetSet.allObjects];
    
    KLDispatchMainAsync(^{
        [self didChangeContent];
        [self didChangeSelection];
    });
}

@end
