//
//  KLFaceViewController.m
//  Raffle
//
//  Created by Killua Liu on 12/22/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLFaceViewController.h"
#import "KLScaleTransition.h"
#import "KLPhotoCell.h"
#import "KLAlbumViewController.h"
#import "KLCameraViewController.h"

@interface KLFaceViewController ()

@property (nonatomic, strong) NSMutableArray<UIImage *> *images;
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *selectedIndexPaths;
@property (nonatomic, assign, getter=isDeleteMode) BOOL deleteMode;

@property (nonatomic, strong) UIBarButtonItem *backButtonItem;
@property (nonatomic, strong) UIBarButtonItem *doneButtonItem;

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
        self.images = [NSMutableArray arrayWithArray:images];
        self.selectedIndexPaths = [NSMutableArray array];
        self.transition = [KLScaleTransition transitionWithGestureEnabled:YES];
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
    self.backButtonItem = [UIBarButtonItem barButtonItemWithImageName:@"icon_back" target:self action:@selector(backFromFaceVC:)];
    self.doneButtonItem = [UIBarButtonItem barButtonItemWithSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addFacePhotosToDrawBox:)];
    self.navigationItem.leftBarButtonItem = self.backButtonItem;
    self.navigationItem.rightBarButtonItem = self.doneButtonItem;
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = cellItemSize;
    flowLayout.minimumLineSpacing = lineSpacing;
    flowLayout.minimumInteritemSpacing = lineSpacing;
    
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.backgroundColor = [UIColor darkBackgroundColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.collectionView.contentInset = IS_PAD ? UIEdgeInsetsMake(lineSpacing, lineSpacing, lineSpacing, lineSpacing) : UIEdgeInsetsMake(2, 0, 2, 0);
    [self.collectionView registerClass:[KLPhotoCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
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
    KLPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    self.images[indexPath.item].selected = YES;
    [self.selectedIndexPaths addObject:indexPath];
    [self updateUI];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.images[indexPath.item].selected = NO;
    [self.selectedIndexPaths removeObject:indexPath];
    [self updateUI];
}

- (void)updateUI
{
    // Only if right bar button is "Delete" icon, need check enablement.
    if (self.isDeleteMode) {
        self.navigationItem.rightBarButtonItem.enabled = self.selectedIndexPaths.count > 0;
    }
    
    if (self.isDeleteMode && self.images.count == 0) {
        [self backFromFaceVC:nil];
    }
}

#pragma mark - Event handing
- (void)longPressToMultiSelectFacePhotos:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;
    
    self.deleteMode = YES;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(id)recognizer.view];
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
}

- (void)backFromFaceVC:(id)sender
{
    [self.images removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addFacePhotosToDrawBox:(id)sender
{
    UIViewController __kindof *presentingViewController = self.presentingViewController;
    KLVoidBlockType completionBlock = ^{
        presentingViewController.view.alpha = 1.0;
        presentingViewController.view.transform = CGAffineTransformIdentity;
        [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
    };
    
    if ([presentingViewController respondsToSelector:@selector(saveImagesToPhotoAlbum:completion:)]) {
        [presentingViewController saveImagesToPhotoAlbum:self.images completion:completionBlock];
    } else {
        completionBlock();
    }
}

- (void)deleteSelectedFacePhotos:(id)sender
{
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TITLE_CANCEL style:UIAlertActionStyleCancel handler:nil];
    NSUInteger selCount = self.selectedIndexPaths.count;
    NSString *title = selCount > 1 ? [NSString stringWithFormat:TITLE_DELETE_PHOTO_COUNT_OTHER, selCount] : TITLE_DELETE_PHOTO_COUNT_ONE;
    UIAlertAction *delete = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        [self.selectedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
            [indexSet addIndex:indexPath.item];
        }];
        
        [self.images removeObjectsAtIndexes:indexSet];
        [self.collectionView deleteItemsAtIndexPaths:self.selectedIndexPaths];
        [self clearSelection];
        [self updateUI];
    }];
    
    UIAlertController *alertController = [UIAlertController actionSheetControllerWithActions:@[delete, cancel]];
    alertController.popoverPresentationController.sourceView = self.view;
    alertController.popoverPresentationController.sourceRect = self.navigationBar.frame;
    [alertController show];
}

- (void)cancelMultiPhotoSelection:(id)sender
{
    self.deleteMode = NO;
    [self clearSelection];
    [self reloadData];
}

- (void)clearSelection
{
    [self.images setValue:@(NO) forKey:@"selected"];
    [self.selectedIndexPaths removeAllObjects];
}

- (void)setDeleteMode:(BOOL)deleteMode
{
    _deleteMode = deleteMode;
    self.collectionView.allowsMultipleSelection = deleteMode;
    
    if (deleteMode) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelMultiPhotoSelection:)];
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithImageName:@"icon_delete" target:self action:@selector(deleteSelectedFacePhotos:)];

        [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(KLPhotoCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            [cell animateSpringScale];
        }];
    } else {
        self.navigationItem.leftBarButtonItem = self.backButtonItem;
        self.navigationItem.rightBarButtonItem = self.doneButtonItem;
    }
}

@end
