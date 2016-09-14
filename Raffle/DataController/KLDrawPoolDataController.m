//
//  KLDrawPoolDataController.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawPoolDataController.h"

@interface KLDrawPoolDataController ()

@property (nonatomic, strong) KLDrawPoolModel *drawPool;

@end

@implementation KLDrawPoolDataController

- (instancetype)initWithModel:(KLDrawPoolModel *)model
{
    if (self = [self init]) {
        _drawPool = model;
    }
    return self;
}

- (NSUInteger)itemCount
{
    return self.drawPool.photoCount;
}

- (PHAsset *)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return self.drawPool.assets[indexPath.item];
}

- (void)addPhotos:(NSArray<PHAsset *> *)assets
{
    if (self.drawPool.isInserted) {
        [[NSManagedObjectContext MR_rootSavingContext] MR_saveOnlySelfAndWait];
    }
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            KLPhotoModel *photoModel = [KLPhotoModel MR_createEntityInContext:localContext];
            photoModel.assetLocalIdentifier = asset.localIdentifier;
            photoModel.drawPool = [self.drawPool MR_inContext:localContext];
        }];
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        if (error) {
            KLLog(@"%@", error);
        } else {
            [self didChangeContent];
        }
    }];
}

- (void)didChangeContent
{
    if ([self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
        [self.delegate controllerDidChangeContent:self];
    }
}

@end
