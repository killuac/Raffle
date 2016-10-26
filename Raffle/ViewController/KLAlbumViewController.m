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

@interface KLAlbumViewController ()

@property (nonatomic, strong) KLPhotoLibrary *photoLibrary;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end

@implementation KLAlbumViewController

static CGSize cellItemSize;
static CGFloat lineSpacing;

+ (void)load
{
    CGFloat width, height;
    lineSpacing = IS_PAD ? 12 : 3;
    NSUInteger columnCount = IS_PAD ? 5 : 4;
    NSUInteger spacingCount = IS_PAD ? columnCount + 1 : columnCount - 1;
    width = height = (SCREEN_WIDTH - lineSpacing * spacingCount) / columnCount;
    cellItemSize = CGSizeMake(width, height);
}

#pragma mark - Lifecycle
+ (instancetype)viewControllerWithPhotoLibrary:(KLPhotoLibrary *)photoLibrary atPageIndex:(NSUInteger)pageIndex
{
    return [[self alloc] initWithPhotoLibrary:photoLibrary atPageIndex:pageIndex];
}

- (instancetype)initWithPhotoLibrary:(KLPhotoLibrary *)photoLibrary atPageIndex:(NSUInteger)pageIndex
{
    if (self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]]) {
        _photoLibrary = photoLibrary;
        _pageIndex = pageIndex;
        _assetCollection = [photoLibrary assetCollectionAtIndex:pageIndex];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
    [self addObservers];
    [self reloadData];
}

- (void)prepareForUI
{
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = cellItemSize;
    flowLayout.minimumLineSpacing = lineSpacing;
    flowLayout.minimumInteritemSpacing = lineSpacing;
    
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.collectionView.contentInset = IS_PAD ? UIEdgeInsetsMake(lineSpacing, lineSpacing, lineSpacing, lineSpacing) : UIEdgeInsetsMake(2, 0, 2, 0);
    [self.collectionView registerClass:[KLAlbumCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
}

#pragma mark - Observer
- (void)addObservers
{
    self.KVOController = [FBKVOController controllerWithObserver:self];
    [self.KVOController observe:self.assetCollection keyPath:NSStringFromSelector(@selector(assets)) options:0 action:@selector(reloadData)];
}

- (void)reloadData
{
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];   // Must call it for set content offset working
    
    if (!CGPointEqualToPoint(self.assetCollection.contentOffset, CGPointZero)) {
        [self.collectionView setContentOffset:self.assetCollection.contentOffset];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetCollection.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KLAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    PHAsset *asset = self.assetCollection.assets[indexPath.item];
    [cell configWithAsset:asset];
    
    if (asset.isSelected) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self.photoLibrary selectAsset:self.assetCollection.assets[indexPath.item]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.photoLibrary deselectAsset:self.assetCollection.assets[indexPath.item]];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.assetCollection.contentOffset = scrollView.contentOffset;
}

@end
