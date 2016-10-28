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

@property (nonatomic, strong) NSArray <KLDrawBoxModel *> *drawBoxes;

@end

@implementation KLMainDataController

- (instancetype)init
{
    if (self = [super init]) {
        _drawBoxes = [KLDrawBoxModel MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]];
        if (self.pageCount == 0) {
            _drawBoxes = @[[KLDrawBoxModel MR_createEntityInContext:[NSManagedObjectContext MR_rootSavingContext]]];
        }
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
    // TODO: Add draw box
}

- (void)deleteDrawBoxAtIndexPath:(NSIndexPath *)indexPath
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        KLDrawBoxModel *drawBox = [self objectAtIndexPath:indexPath];
        [drawBox MR_deleteEntity];
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
    [self willChangeValueForKey:NSStringFromSelector(@selector(drawBoxes))];
    // TODO: Remove draw box that don't exist in photo library
    self.drawBoxes = [KLDrawBoxModel MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]];
    [self didChangeValueForKey:NSStringFromSelector(@selector(drawBoxes))];
}

@end
