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

@end

@implementation KLMainDataController

- (instancetype)init
{
    if (self = [super init]) {
        _drawBoxes = [NSMutableArray arrayWithArray:[KLDrawBoxModel MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]]];
    }
    return self;
}

- (KLDrawBoxDataController *)currentDrawBoxDC
{
    return [self drawBoxDataControllerAtIndex:self.currentPageIndex];
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
    DECLARE_WEAK_SELF;
    NSUInteger itemIndex = self.itemCount;
    
    KLDrawBoxModel *drawBox = [KLDrawBoxModel MR_createEntityInContext:[NSManagedObjectContext MR_rootSavingContext]];
    [self.drawBoxes addObject:drawBox];
    
    KLDrawBoxDataController *drawBoxDC = [self drawBoxDataControllerAtIndex:itemIndex];
    [drawBoxDC addPhotos:assets completion:^{
        [welf didChangeAtIndexPaths:@[[NSIndexPath indexPathForItem:itemIndex inSection:0]] forChangeType:KLDataChangeTypeInsert];
    }];
}

- (void)deleteDrawBoxAtIndexPath:(NSIndexPath *)indexPath
{
    KLDrawBoxModel *drawBox = [self objectAtIndexPath:indexPath];
    [self.drawBoxes removeObject:drawBox];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        [drawBox MR_deleteEntityInContext:localContext];
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        [self didChangeAtIndexPaths:@[indexPath] forChangeType:KLDataChangeTypeDelete];
    }];
}

- (KLDrawBoxDataController *)drawBoxDataControllerAtIndex:(NSUInteger)index
{
    KLDrawBoxDataController *dataController = [KLDrawBoxDataController dataControllerWithModel:self.drawBoxes[index]];
    dataController.pageIndex = index;
    return dataController;
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
    [self.drawBoxes removeAllObjects];
    [self.drawBoxes addObjectsFromArray:[KLDrawBoxModel MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]]];
    [self didChangeContent];
}

@end
