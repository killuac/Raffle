//
//  KLDrawBoxViewController.m
//  Raffle
//
//  Created by Killua Liu on 7/30/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawBoxViewController.h"
#import "KLMainViewController.h"
#import "KLImagePickerController.h"
#import "KLCircleLayout.h"
#import "KLDrawBoxCell.h"

@interface KLDrawBoxViewController () <KLDataControllerDelegate, KLImagePickerControllerDelegate>

@property (nonatomic, strong) KLMainDataController *mainDC;
@property (nonatomic, strong) KLDrawBoxDataController *drawBoxDC;

@end

@implementation KLDrawBoxViewController

#pragma mark - Life cycle
+ (instancetype)viewControllerWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex
{
    return [[self alloc] initWithDataController:dataController atPageIndex:pageIndex];
}

- (instancetype)initWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex
{
    if (self = [super initWithCollectionViewLayout:[KLCircleLayout new]]) {
        _mainDC = dataController;
        _drawBoxDC = [dataController drawBoxDataControllerAtIndex:pageIndex];
        _drawBoxDC.delegate = self;
    }
    return self;
}

- (NSUInteger)pageIndex
{
    return self.drawBoxDC.pageIndex;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
}

- (void)prepareForUI
{
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.collectionView registerClass:[KLDrawBoxCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.drawBoxDC.itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KLDrawBoxCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    [cell configWithAsset:[self.drawBoxDC objectAtIndexPath:indexPath]];
    
    return cell;
}

#pragma mark - Data controller delegate
- (void)controller:(KLDataController *)controller didChangeAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths forChangeType:(KLDataChangeType)type
{
    switch (type) {
        case KLDataChangeTypeInsert:
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
            break;
            
        case KLDataChangeTypeDelete:
            [self.collectionView deleteItemsAtIndexPaths:indexPaths];
            break;
            
        default:
            break;
    }
}

#pragma mark - KLImagePickerController delegate
- (void)imagePickerController:(KLImagePickerController *)picker didFinishPickingImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.drawBoxDC addPhotos:assets];
}

@end
