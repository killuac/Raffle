//
//  PHAssetCollection+Model.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "PHAssetCollection+Model.h"

@implementation PHAssetCollection (Model)

- (void)setIndexPath:(NSIndexPath *)indexPath
{
    objc_setAssociatedObject(self, @selector(indexPath), indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSIndexPath *)indexPath
{
    return objc_getAssociatedObject(self, @selector(indexPath));
}

- (void)setFetchResult:(PHFetchResult *)fetchResult
{
    objc_setAssociatedObject(self, @selector(fetchResult), fetchResult, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PHFetchResult *)fetchResult
{
    PHFetchResult *results = objc_getAssociatedObject(self, @selector(fetchResult));
    if (!results) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(creationDate)) ascending:NO]];
        results = [PHAsset fetchAssetsInAssetCollection:self options:options];
    }
    return results;
}

- (NSUInteger)assetCount
{
    return self.fetchResult.count;
}

- (void)fetchAssets
{
    KLDispatchGlobalAsync(^{
        NSMutableArray *assetArray = [NSMutableArray array];
        [self.fetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            if (asset) [assetArray addObject:asset];
        }];
        
        KLDispatchMainAsync(^{
            [self setAssets:assetArray];
        });
    });
}

- (void)setAssets:(NSArray<PHAsset *> *)assets
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(assets))];
    objc_setAssociatedObject(self, @selector(assets), assets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:NSStringFromSelector(@selector(assets))];
}

- (NSArray<PHAsset *> *)assets
{
    return objc_getAssociatedObject(self, @selector(assets));
}

- (void)posterImage:(KLAssetBlockType)resultHandler
{
    [self.assets.lastObject thumbnailImageProgressHandler:nil resultHandler:resultHandler];
}

@end
