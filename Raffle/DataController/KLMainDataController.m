//
//  KLMainDataController.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLMainDataController.h"
#import "KLDrawBoxModel.h"

@interface KLMainDataController () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) NSMutableArray <KLDrawBoxModel *> *drawBoxes;
@property (nonatomic, strong) NSMutableArray <KLDrawBoxDataController *> *drawBoxDCs;

@end

@implementation KLMainDataController

- (instancetype)init
{
    if (self = [super init]) {
        NSArray *array = [KLDrawBoxModel MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"photos.@count > 0"] inContext:[NSManagedObjectContext MR_rootSavingContext]];
        _drawBoxes = [NSMutableArray arrayWithArray:array];
        _drawBoxDCs = [NSMutableArray array];
        
        [self.drawBoxes enumerateObjectsUsingBlock:^(KLDrawBoxModel * _Nonnull drawBoxModel, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.drawBoxDCs addObject:[self createDrawBoxDataControllerWithPageIndex:idx]];
        }];
        
        [self addObservers];
    }
    return self;
}

- (KLDrawBoxDataController *)createDrawBoxDataControllerWithPageIndex:(NSUInteger)pageIndex
{
    KLDrawBoxDataController *dataController = [KLDrawBoxDataController dataControllerWithModel:self.drawBoxes[pageIndex]];
    dataController.pageIndex = pageIndex;
    return dataController;
}

- (KLDrawBoxDataController *)currentDrawBoxDC
{
    return self.pageCount > 0 ? self.drawBoxDCs[self.currentPageIndex] : nil;
}

- (NSUInteger)pageCount
{
    return self.drawBoxes.count;
}

- (NSUInteger)itemCount
{
    return self.pageCount;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return self.drawBoxes[indexPath.item];
}

- (BOOL)isAttendeeMode
{
    return self.currentDrawBoxDC.isAttendeeMode;
}

- (BOOL)isReloadButtonHidden
{
    return self.currentDrawBoxDC.isReloadButtonHidden;
}

- (void)switchDrawMode
{
    [self.currentDrawBoxDC switchDrawMode];
}

- (void)addDrawBoxWithAssets:(NSArray<PHAsset *> *)assets
{
    __weak typeof(self) weakSelf = self;
    NSUInteger itemIndex = self.itemCount;
    
    KLDrawBoxModel *drawBox = [KLDrawBoxModel MR_createEntityInContext:[NSManagedObjectContext MR_rootSavingContext]];
    [self.drawBoxes addObject:drawBox];
    
    KLDrawBoxDataController *drawBoxDC = [self createDrawBoxDataControllerWithPageIndex:itemIndex];
    [self.drawBoxDCs addObject:drawBoxDC];
    [drawBoxDC addPhotos:assets completion:^{
        [weakSelf didChangeAtIndexPaths:@[[NSIndexPath indexPathForItem:itemIndex inSection:0]] forChangeType:KLDataChangeTypeInsert];
    }];
}

- (void)deleteDrawBoxAtIndexPath:(NSIndexPath *)indexPath
{
    KLDrawBoxModel *drawBox = [self objectAtIndexPath:indexPath];
    [self.drawBoxes removeObject:drawBox];
    [self.drawBoxDCs removeObjectAtIndex:indexPath.item];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [drawBox MR_deleteEntityInContext:localContext];
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        [self didChangeAtIndexPaths:@[indexPath] forChangeType:KLDataChangeTypeDelete];
    }];
}

- (KLDrawBoxDataController *)drawBoxDataControllerAtIndex:(NSUInteger)index
{
    return self.drawBoxDCs[index];
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
    [self.drawBoxes filterUsingPredicate:[NSPredicate predicateWithFormat:@"photos.@count > 0"]];
    KLDispatchMainAsync(^{
        [self didChangeContent];
    });
}

@end
