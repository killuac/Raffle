//
//  KLFaceViewController.m
//  Raffle
//
//  Created by Killua Liu on 12/22/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLFaceViewController.h"
#import "KLScaleTransition.h"
#import "KLAlbumCell.h"

@interface KLFaceViewController ()

@property (nonatomic, strong) NSArray<UIImage *> *images;
@property (nonatomic, assign, getter=isDeleteMode) BOOL deleteMode;

@end

@implementation KLFaceViewController

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

+ (instancetype)viewControllerWithImages:(NSArray<UIImage *> *)images
{
    return [[self alloc] initWithImages:images];
}

- (instancetype)initWithImages:(NSArray *)images
{
    if (self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]]) {
        _images = images;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
}

- (void)prepareForUI
{
    self.title = TITLE_FACE_PHOTOS;
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImageName:@"icon_back" target:self action:@selector(backFromFaceVC:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithSystemItem:UIBarButtonSystemItemDone target:self action:@selector(tapRightNavBarButton:)];
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = cellItemSize;
    flowLayout.minimumLineSpacing = lineSpacing;
    flowLayout.minimumInteritemSpacing = lineSpacing;
    
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.backgroundColor = [UIColor darkBackgroundColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.collectionView.contentInset = IS_PAD ? UIEdgeInsetsMake(lineSpacing, lineSpacing, lineSpacing, lineSpacing) : UIEdgeInsetsMake(2, 0, 2, 0);
    [self.collectionView registerClass:[KLAlbumCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
}

- (void)reloadData
{
    if (self.images.count > 0) {
        [self.collectionView reloadData];
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KLAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.imageView.image = self.images[indexPath.item];
    cell.selected = cell.imageView.image.isSelected;
    cell.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToMultiSelectFacePhotos:)];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.item == self.images.count) ? YES : self.deleteMode;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.item == self.images.count) ? YES : self.deleteMode;
}

#pragma mark - Event handing
- (void)longPressToMultiSelectFacePhotos:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;
    
    if (!self.deleteMode) {
        self.deleteMode = YES;
    }
    
    KLAlbumCell *cell = (id)recognizer.view;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    self.images[indexPath.item].selected = YES;
    
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
    [self reloadData];
}

- (void)backFromFaceVC:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapRightNavBarButton:(id)sender
{
    if (self.deleteMode) {
        [self deleteSelectedFacePhotos:sender];
    } else {
        [self addFacePhotosToDrawBox:sender];
    }
}

- (void)addFacePhotosToDrawBox:(id)sender
{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteSelectedFacePhotos:(id)sender
{
    
}

- (void)cancelMultiPhotoSelection:(id)sender
{
    self.deleteMode = NO;
    [self reloadData];
    self.navigationItem.rightBarButtonItem.enabled = self.images.count > 0;
}

- (void)setDeleteMode:(BOOL)deleteMode
{
    _deleteMode = deleteMode;
    self.collectionView.allowsMultipleSelection = deleteMode;
    
    if (deleteMode) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelMultiPhotoSelection:)];
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_delete"];
        self.navigationItem.rightBarButtonItem.title = nil;
        
        [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(KLAlbumCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            [cell animateSpringScale];
        }];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem.title = TITLE_START;
        self.navigationItem.rightBarButtonItem.image = nil;
    }
}


@end
