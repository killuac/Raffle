//
//  KLDrawBoxDataController.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawBoxDataController.h"

@interface KLDrawBoxDataController ()

@property (nonatomic, strong) KLDrawBoxModel *drawBox;
@property (nonatomic, strong) NSMutableArray *allAssets;

@end

@implementation KLDrawBoxDataController

- (instancetype)initWithModel:(KLDrawBoxModel *)model
{
    if (self = [self init]) {
        _drawBox = model;
        _allAssets = [NSMutableArray arrayWithArray:_drawBox.assets];
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

- (void)reloadAssets
{
    [self.allAssets removeAllObjects];
    [self.allAssets addObjectsFromArray:self.drawBox.assets];
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

- (NSUInteger)randomAnAssetIndex
{
    return KLRandomNumber(0, self.itemCount);
}

@end
