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

@property (nonatomic, strong) PHAssetCollection *cameraRollCollection;
@property (nonatomic, strong) PHAssetCollection *appAssetCollection;

@end

@implementation KLPhotoLibrary

#pragma mark - Lifecycle
- (instancetype)init
{
    if (self = [super init]) {
        _assetCollectionArray = [NSMutableArray array];
        _selectedAssetArray = [NSMutableArray array];
        [self fetchAssetCollections:nil];
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
                                asset.selected = YES;
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
    
    KLDispatchGroupGlobalAsync(group, ^{
        [self fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum options:options];
        [self fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum options:nil];
    });
    
    KLDispatchGroupMainNotify(group, ^{
        [self willChangeValueForKey:NSStringFromSelector(@selector(assetCollections))];
        [self.cameraRollCollection removeAssets:self.appAssetCollection.assets];
        [self.assetCollectionArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(assetCount)) ascending:NO]]];
        if (completion) completion();
        [self didChangeValueForKey:NSStringFromSelector(@selector(assetCollections))];
    });
}

- (void)fetchAssetCollectionsWithType:(PHAssetCollectionType)type options:(PHFetchOptions *)options
{
    PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:PHAssetCollectionSubtypeAny options:options];
    [results enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self isFetchForSubtype:collection.assetCollectionSubtype]) {
            @synchronized (self) {
                if (collection.assetCount > 0 && ![self.assetCollectionArray containsObject:collection]) {
                    [collection fetchAssets:nil];
                    [self.assetCollectionArray addObject:collection];
                    
                    if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                        self.cameraRollCollection = collection;
                    }
                    if ([collection.localizedTitle isEqualToString:APP_DISPLAY_NAME]) {
                        self.appAssetCollection = collection;
                    }
                }
            }
        }
    }];
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
    NSUInteger index = [self.assetCollectionArray indexOfObject:self.appAssetCollection];
    if (index != NSNotFound && self.appAssetCollection.assetCount > 0) {
        [self.assetCollectionArray exchangeObjectAtIndex:index withObjectAtIndex:1];    // Move App Album to 2nd position
    }
    return self.assetCollectionArray;
}

- (NSUInteger)pageCount
{
    return self.assetCollections.count;
}

- (NSArray<NSString *> *)segmentTitles
{
    return [self.assetCollections valueForKeyPath:@"@unionOfObjects.localizedTitle"];
}

- (PHAssetCollection *)assetCollectionAtIndex:(NSUInteger)index
{
    PHAssetCollection *assetCollection = self.assetCollections[index];
    [assetCollection.assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        asset.selected = [self.selectedAssetArray containsObject:asset];
    }];
    return assetCollection;
}

- (NSArray<PHAsset *> *)selectedAssets
{
    return self.selectedAssetArray;
}

//- (NSMutableArray *)selectedAssetArray
//{
//    return [self mutableArrayValueForKey:@"_selectedAssetArray"];   // For KVO
//}

#pragma mark - Update assets
- (void)selectAsset:(PHAsset *)asset
{
    [self willChangeValueForSelectedAssets];
    asset.selected = YES;
    if (![self.selectedAssetArray containsObject:asset]) {
        [self.selectedAssetArray addObject:asset];
    }
    [self didChangeValueForSelectedAssets];
}

- (void)deselectAsset:(PHAsset *)asset
{
    [self willChangeValueForSelectedAssets];
    asset.selected = NO;
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

#pragma mark - Save images
+ (void)saveImages:(NSArray<UIImage *> *)images completion:(KLObjectBlockType)completion
{
    NSMutableArray<PHObjectPlaceholder *> *placeholders = [NSMutableArray array];
    __block PHAssetCollection *appAssetCollection;
    
    PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    [results enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([collection.localizedTitle isEqualToString:APP_DISPLAY_NAME]) {
            appAssetCollection = collection;
            *stop = YES;
        }
    }];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCollectionChangeRequest *collectionRequest;
        if (appAssetCollection) {
            collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:appAssetCollection];
        } else {
            collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:APP_DISPLAY_NAME];
        }
        
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            [placeholders addObject:assetRequest.placeholderForCreatedAsset];
        }];
        
        [collectionRequest addAssets:placeholders];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            KLDispatchMainAsync(^{
                if (completion) completion([self fetchAssetsWithPlaceholders:placeholders]);
            });
        } else {
            KLLog(@"Save images error: %@", error.localizedDescription);
        }
    }];
}

+ (NSArray<PHAsset *> *)fetchAssetsWithPlaceholders:(NSArray<PHObjectPlaceholder *> *)placeholders
{
    NSMutableArray *assets = [NSMutableArray array];
    NSArray *localIdentifiers = [placeholders valueForKeyPath:@"@unionOfObjects.localIdentifier"];
    PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers:localIdentifiers options:nil];
    [results enumerateObjectsUsingBlock:^(id  _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [assets addObject:asset];
    }];
    
    return assets;
}

@end
