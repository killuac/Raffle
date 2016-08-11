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
            [self fetchAssetCollections];
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
        _selectedAssets = [NSMutableArray array];
        _assetCollections = [NSMutableArray array];
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

- (void)setAssetCollections:(NSArray<PHAssetCollection *> *)assetCollections
{
    if (assetCollections.count) {
        _assetCollections = assetCollections;
    }
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    [self fetchAssetCollections];
}

#pragma mark - Public method
- (NSUInteger)currentPageIndex
{
    if (_currentPageIndex == ULONG_MAX) {
        return 0;
    }
    if (_currentPageIndex >= self.assetCollectionCount) {
        return self.assetCollectionCount - 1;
    }
    return _currentPageIndex;
}

- (NSArray<NSString *> *)assetCollectionTitles
{
    return [self.assetCollections valueForKeyPath:@"@unionOfObjects.localizedTitle"];
}

- (NSUInteger)assetCollectionCount
{
    return self.assetCollections.count;
}

- (BOOL)isPageScrollEnabled
{
    return self.assetCollectionCount > 0;
}

- (void)fetchAssetCollections
{
    _assetCollectionArray = [NSMutableArray array];
    
    dispatch_group_t group = dispatch_group_create();
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    
    [self fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum options:options inGCDGroup:group];
    [self fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum options:nil inGCDGroup:group];
    
    KLDispatchGroupMainNotify(group, ^{
        [self.assetCollectionArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(assetCount)) ascending:NO]]];
        self.assetCollections = self.assetCollectionArray;
    });
}

- (void)fetchAssetCollectionsWithType:(PHAssetCollectionType)type options:(PHFetchOptions *)options inGCDGroup:(dispatch_group_t)group
{
    KLDispatchGroupGlobalAsync(group, ^{
        PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:PHAssetCollectionSubtypeAny options:options];
        [results enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self isFetchForSubtype:collection.assetCollectionSubtype]) {
                @synchronized (self) {
                    if (collection.assetCount > 0) {
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

- (PHAssetCollection *)assetCollectionAtIndex:(NSUInteger)index
{
    PHAssetCollection *assetCollection = self.assetCollections[index];
    [assetCollection fetchAssets];
    return assetCollection;
}

- (NSUInteger)assetCountAtIndex:(NSUInteger)index
{
    return [self assetCollectionAtIndex:index].assets.count;
}

- (void)addAsset:(PHAsset *)asset
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(selectedAssets))];
    [self.selectedAssets addObject:asset];
    [self didChangeValueForKey:NSStringFromSelector(@selector(selectedAssets))];
}

- (void)removeAsset:(PHAsset *)asset
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(selectedAssets))];
    [self.selectedAssets removeObject:asset];
    [self didChangeValueForKey:NSStringFromSelector(@selector(selectedAssets))];
}

@end
