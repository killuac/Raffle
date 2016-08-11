//
//  KLAlbumViewController.m
//  Raffle
//
//  Created by Killua Liu on 3/18/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLAlbumViewController.h"
#import "KLAlbumCell.h"
#import "KLImagePickerController.h"

const CGFloat KLLineSpacing = 3.0;

@interface KLAlbumViewController ()

@property (nonatomic, strong) KLPhotoLibrary *photoLibrary;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end

@implementation KLAlbumViewController

static CGSize cellItemSize;

+ (void)load
{
    CGFloat width, height;
    width = height = (SCREEN_WIDTH - KLLineSpacing * 3) / 4;
    cellItemSize = CGSizeMake(width, height);
}

+ (instancetype)viewControllerWithPageIndex:(NSUInteger)pageIndex photoLibrary:(KLPhotoLibrary *)photoLibrary
{
    return [[self alloc] initWithPageIndex:pageIndex photoLibrary:photoLibrary];
}

- (instancetype)initWithPageIndex:(NSUInteger)pageIndex photoLibrary:(id)photoLibrary
{
    if (self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]]) {
        _pageIndex = pageIndex;
        _photoLibrary = photoLibrary;
        _assetCollection = [self.photoLibrary assetCollectionAtIndex:pageIndex];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
    [self addObservers];
}

- (void)prepareForUI
{
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = cellItemSize;
    flowLayout.minimumLineSpacing = KLLineSpacing;
    flowLayout.minimumInteritemSpacing = KLLineSpacing;
    
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerClass:[KLAlbumCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
}

- (void)addObservers
{
    self.KVOController = [FBKVOController controllerWithObserver:self];
    [self.KVOController observe:self.assetCollection keyPath:NSStringFromSelector(@selector(assets)) options:0 action:@selector(reloadData)];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetCollection.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KLAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    [cell configWithAsset:self.assetCollection.assets[indexPath.item]];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self.photoLibrary addAsset:self.assetCollection.assets[indexPath.item]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.photoLibrary removeAsset:self.assetCollection.assets[indexPath.item]];
}

@end
