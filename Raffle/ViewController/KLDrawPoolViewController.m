//
//  KLDrawPoolViewController.m
//  Raffle
//
//  Created by Killua Liu on 7/30/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawPoolViewController.h"
#import "KLMainViewController.h"
#import "KLImagePickerController.h"
#import "KLCircleLayout.h"
#import "KLDrawPoolCell.h"

@interface KLDrawPoolViewController () <KLDataControllerDelegate, KLImagePickerControllerDelegate>

@property (nonatomic, strong) KLMainDataController *mainDC;
@property (nonatomic, strong) KLDrawPoolDataController *drawPoolDC;

@end

@implementation KLDrawPoolViewController

#pragma mark - Life cycle
+ (instancetype)viewControllerWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex
{
    return [[self alloc] initWithDataController:dataController atPageIndex:pageIndex];
}

- (instancetype)initWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex
{
    if (self = [super initWithCollectionViewLayout:[KLCircleLayout new]]) {
        _mainDC = dataController;
        _drawPoolDC = [dataController drawPoolDataControllerAtIndex:pageIndex];
        _drawPoolDC.delegate = self;
    }
    return self;
}

- (NSUInteger)pageIndex
{
    return self.drawPoolDC.pageIndex;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
}

- (void)prepareForUI
{
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.collectionView registerClass:[KLDrawPoolCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.drawPoolDC.itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KLDrawPoolCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    [cell configWithAsset:[self.drawPoolDC objectAtIndexPath:indexPath]];
    
    return cell;
}

#pragma mark - Data controller delegate
- (void)controllerDidChangeContent:(KLDrawPoolDataController *)controller
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.drawPoolDC.itemCount; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
}

#pragma mark - KLImagePickerController delegate
- (void)imagePickerController:(KLImagePickerController *)picker didFinishPickingImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.drawPoolDC addPhotos:assets];
}

#pragma mark - Event handling
- (void)startDraw:(id)sender
{
    
}

- (void)stopDraw:(id)sender
{
    
}

- (void)shakeToStart:(id)sender
{
    
}

- (void)switchDrawMode:(id)sender
{
//    TODO: Show or Hide reload button
}

@end
