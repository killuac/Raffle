//
//  PHAssetCollection+Model.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "PHAssetCollection+Model.h"

@interface PHAssetCollection (Private)

@property (nonatomic, strong) NSMutableArray<PHAsset *> *assetArray;

@end

@implementation PHAssetCollection (Model)

- (void)setContentOffset:(CGPoint)contentOffset
{
    objc_setAssociatedObject(self, @selector(contentOffset), [NSValue valueWithCGPoint:contentOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)contentOffset
{
    return [objc_getAssociatedObject(self, @selector(contentOffset)) CGPointValue];
}

#pragma mark - Fetch assets
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
        [self setFetchResult:[PHAsset fetchAssetsInAssetCollection:self options:options]];
    }
    return objc_getAssociatedObject(self, @selector(fetchResult));
}

- (NSUInteger)assetCount
{
    return self.fetchResult.count;
}

- (void)fetchAssets:(KLVoidBlockType)completion
{
    [self removeAllAssets];
    
    dispatch_block_t block = ^{
        NSMutableArray *assetArray = [NSMutableArray array];
        [self.fetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            if (asset) [assetArray addObject:asset];
        }];
        
        KLDispatchMainAsync(^{
            [self willChangeValueForKey:NSStringFromSelector(@selector(assets))];
            [self setAssetArray:assetArray];
            if (completion) completion();
            [self didChangeValueForKey:NSStringFromSelector(@selector(assets))];
        });
    };
    
    [NSThread isMainThread] ? KLDispatchGlobalAsync(block) : block();
}

- (void)setAssetArray:(NSMutableArray<PHAsset *> *)assetArray
{
    objc_setAssociatedObject(self, @selector(assetArray), assetArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<PHAsset *> *)assetArray
{
    return objc_getAssociatedObject(self, @selector(assetArray));
}

- (NSArray<PHAsset *> *)assets
{
    return self.assetArray;
}

#pragma mark - Update
- (void)updateWithAssetCollection:(PHAssetCollection *)collection
{
    self.contentOffset = collection.contentOffset;
    [self addAssetsFromArray:collection.assets];
}

- (void)addAssetsFromArray:(NSArray *)assetArray
{
    if (assetArray.count) {
        if (!self.assetArray) self.assetArray = [NSMutableArray array];
        [self.assetArray addObjectsFromArray:assetArray];
    }
}

- (void)removeAllAssets
{
    self.fetchResult = nil;
    [self.assetArray removeAllObjects];
}

#pragma mark - Poster
- (void)posterImage:(KLAssetBlockType)resultHandler
{
    [self.assets.lastObject thumbnailImageProgressHandler:nil resultHandler:resultHandler];
}

@end
