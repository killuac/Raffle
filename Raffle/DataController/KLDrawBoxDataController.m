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

@end

@implementation KLDrawBoxDataController

- (instancetype)initWithModel:(KLDrawBoxModel *)model
{
    if (self = [self init]) {
        _drawBox = model;
    }
    return self;
}

- (NSUInteger)itemCount
{
    return self.drawBox.photoCount;
}

- (PHAsset *)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return self.drawBox.assets[indexPath.item];
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

@end
