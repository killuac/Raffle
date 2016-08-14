//
//  KLPhotoLibrary.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLPhotoLibrary.h"

@interface KLPhotoLibrary () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong, readonly) PHPhotoLibrary *photoLibrary;
@property (nonatomic, strong) NSMutableArray *assetCollectionArray;
@property (nonatomic, strong) NSMutableArray *selectedAssetArray;

@end

@implementation KLPhotoLibrary

- (void)checkAuthorization:(KLVoidBlockType)handler
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (PHAuthorizationStatusNotDetermined == status) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            // This callback is not on main thread.
            [self checkPhotoLibraryWithStatus:status handler:handler];
        }];
    } else {
        [self checkPhotoLibraryWithStatus:status handler:handler];
    }
}

- (void)checkPhotoLibraryWithStatus:(NSInteger)status handler:(KLVoidBlockType)handler
{
    dispatch_block_t block = ^{
        if (PHAuthorizationStatusAuthorized == status) {
            [self fetchAssetCollections:nil];
        } else if (PHAuthorizationStatusDenied == status || PHAuthorizationStatusAuthorized == status) {
            handler();
        }
    };
    
    [NSThread isMainThread] ? block() : KLDispatchMainAsync(block);
}

#pragma mark - Lifecycle
- (instancetype)init
{
    if (self = [super init]) {
        _assetCollectionArray = [NSMutableArray array];
        _selectedAssetArray = [NSMutableArray array];
        [self.photoLibrary registerChangeObserver:self];
    }
    return self;
}

- (PHPhotoLibrary *)photoLibrary
{
    return [PHPhotoLibrary sharedPhotoLibrary];
}

- (void)dealloc
{
    [self.photoLibrary unregisterChangeObserver:self];
}

#pragma mark - PHPhotoLibraryChangeObserver
// This callback is invoked on an arbitrary serial queue
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    [self fetchAssetCollections:^{
        NSMutableArray *removedCollections = [NSMutableArray array];
        [self.assetCollectionArray enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
            PHObjectChangeDetails *albumChanges = [changeInstance changeDetailsForObject:collection];
            PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:collection.fetchResult];
            // Change album
            if (albumChanges) {
                if (albumChanges.objectWasDeleted && !collectionChanges) {
                    [removedCollections addObject:collection];  // Remove a collection(album)
                    [self removeSelectedAssetsInArray:collection.assets];
                } else {
                    PHAssetCollection *changedCollection = albumChanges.objectAfterChanges;
                    [changedCollection updateWithAssetCollection:collection];
                    [self.assetCollectionArray replaceObjectAtIndex:idx withObject:changedCollection];
                    collection = changedCollection;
                }
            }
            
            // Change collection
            if (collectionChanges && collectionChanges.hasIncrementalChanges) {
                [self removeSelectedAssetsInArray:collectionChanges.removedObjects];
                if (collectionChanges.fetchResultAfterChanges.count) {
                    [collection fetchAssets:^{
                        [collection.assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                            if ([self.selectedAssets containsObject:asset]) {
                                asset.isSelected = YES;
                            }
                        }];
                    }];
                } else {
                    [removedCollections addObject:collection];
                    [self removeSelectedAssetsInArray:collection.assets];
                }
            }
        }];
        
        [self.assetCollectionArray removeObjectsInArray:removedCollections];
    }];
}

- (void)fetchAssetCollections:(KLVoidBlockType)completion
{
    dispatch_group_t group = dispatch_group_create();
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    
    [self fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum options:options inGCDGroup:group];
    [self fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum options:nil inGCDGroup:group];
    
    KLDispatchGroupMainNotify(group, ^{
        [self willChangeValueForKey:NSStringFromSelector(@selector(assetCollections))];
        [self.assetCollectionArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(assetCount)) ascending:NO]]];
        if (completion) completion();
        [self didChangeValueForKey:NSStringFromSelector(@selector(assetCollections))];
    });
}

- (void)fetchAssetCollectionsWithType:(PHAssetCollectionType)type options:(PHFetchOptions *)options inGCDGroup:(dispatch_group_t)group
{
    KLDispatchGroupGlobalAsync(group, ^{
        PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:PHAssetCollectionSubtypeAny options:options];
        [results enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self isFetchForSubtype:collection.assetCollectionSubtype]) {
                @synchronized (self) {
                    if (collection.assetCount > 0 && ![self.assetCollectionArray containsObject:collection]) {
                        [collection fetchAssets:nil];
                        [self.assetCollectionArray addObject:collection];
                    }
                }
            }
        }];
    });
}

- (BOOL)isFetchForSubtype:(PHAssetCollectionSubtype)subtype
{
    return (PHAssetCollectionSubtypeSmartAlbumPanoramas != subtype      &&
            PHAssetCollectionSubtypeSmartAlbumVideos != subtype         &&
            PHAssetCollectionSubtypeSmartAlbumTimelapses != subtype     &&
            PHAssetCollectionSubtypeSmartAlbumAllHidden != subtype      &&
            PHAssetCollectionSubtypeSmartAlbumRecentlyAdded != subtype  &&
            PHAssetCollectionSubtypeSmartAlbumBursts != subtype         &&
            PHAssetCollectionSubtypeSmartAlbumSlomoVideos != subtype);
}

#pragma mark - Asset collections
- (NSArray<PHAssetCollection *> *)assetCollections
{
    return self.assetCollectionArray;
}

- (NSArray<NSString *> *)assetCollectionTitles
{
    return [self.assetCollections valueForKeyPath:@"@unionOfObjects.localizedTitle"];
}

- (NSUInteger)assetCollectionCount
{
    return self.assetCollections.count;
}

- (NSInteger)currentPageIndex
{
    if (_currentPageIndex == NSNotFound) {
        _currentPageIndex = 0;
    } else if (_currentPageIndex >= self.assetCollectionCount) {
        _currentPageIndex = self.assetCollectionCount - 1;
    }
    return _currentPageIndex;
}

- (BOOL)isPageScrollEnabled
{
    return self.assetCollectionCount > 0;
}

- (PHAssetCollection *)assetCollectionAtIndex:(NSUInteger)index
{
    PHAssetCollection *assetCollection = self.assetCollections[index];
    [assetCollection.assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        asset.isSelected = [self.selectedAssetArray containsObject:asset];
    }];
    return assetCollection;
}

- (NSUInteger)assetCountAtIndex:(NSUInteger)index
{
    return [self assetCollectionAtIndex:index].assets.count;
}

//- (NSMutableArray *)selectedAssetArray
//{
//    return [self mutableArrayValueForKey:@"_selectedAssetArray"];   // For KVO
//}

- (NSArray *)selectedAssets
{
    return self.selectedAssetArray;
}

#pragma mark - Update assets
- (void)selectAsset:(PHAsset *)asset
{
    [self willChangeValueForSelectedAssets];
    asset.isSelected = YES;
    if (![self.selectedAssetArray containsObject:asset]) {
        [self.selectedAssetArray addObject:asset];
    }
    [self didChangeValueForSelectedAssets];
}

- (void)deselectAsset:(PHAsset *)asset
{
    [self willChangeValueForSelectedAssets];
    asset.isSelected = NO;
    [self.selectedAssetArray removeObject:asset];
    [self didChangeValueForSelectedAssets];
}

- (void)removeSelectedAssetsInArray:(NSArray *)array
{
    if (!self.selectedAssetArray.count || !array.count) return;
    
    [self willChangeValueForSelectedAssets];
    [self.selectedAssetArray removeObjectsInArray:array];
    [self didChangeValueForSelectedAssets];
}

- (void)willChangeValueForSelectedAssets
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(selectedAssets))];
}

- (void)didChangeValueForSelectedAssets
{
    [self didChangeValueForKey:NSStringFromSelector(@selector(selectedAssets))];
}

@end
