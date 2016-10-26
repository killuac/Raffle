//
//  KLPhotoViewController.m
//  Raffle
//
//  Created by Killua Liu on 9/19/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLPhotoViewController.h"
#import "KLAlbumCell.h"
#import "KLDrawBoxDataController.h"

const CGFloat KLPhotoViewControllerLineSpacing = 3.0;

@interface KLPhotoViewController ()

@property (nonatomic, strong) KLDrawBoxDataController *drawBoxDC;
@property (nonatomic, assign) BOOL collectionViewAllowsSelection;

@end

@implementation KLPhotoViewController

static CGSize cellItemSize;

+ (void)load
{
    CGFloat width, height;
    width = height = (SCREEN_WIDTH - KLPhotoViewControllerLineSpacing * 3) / 4;
    cellItemSize = CGSizeMake(width, height);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Lifecycle
- (instancetype)initWithDataController:(id)dataController
{
    if (self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]]) {
        _drawBoxDC = dataController;
        _transition = [KLDrawBoxTransition transitionWithGestureEnabled:YES];
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
    self.title = TITLE_DRAW_BOX;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithTitle:BUTTON_TITLE_START target:self action:@selector(tapRightNavBarButton:)];
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = cellItemSize;
    flowLayout.minimumLineSpacing = KLPhotoViewControllerLineSpacing;
    flowLayout.minimumInteritemSpacing = KLPhotoViewControllerLineSpacing;
    
    self.collectionView.allowsSelection = NO;
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(2, 0, 2, 0);
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.collectionView registerClass:[KLAlbumCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
}

#pragma mark - Observer
- (void)addObservers
{
    self.KVOController = [FBKVOController controllerWithObserver:self];
    [self.KVOController observe:self.drawBoxDC keyPath:@"allAssets" options:0 action:@selector(reloadData)];
    [self.KVOController observe:self.drawBoxDC keyPath:@"selectedAssets" options:0 action:@selector(selectedAssetsChanged)];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)selectedAssetsChanged
{
    // Only if right bar button is "Delete" icon, need check enablement.
    if (self.navigationItem.rightBarButtonItem.image) {
        self.navigationItem.rightBarButtonItem.enabled = self.drawBoxDC.selectedAssetCount > 0;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.drawBoxDC.itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KLAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    PHAsset *asset = [self.drawBoxDC objectAtIndexPath:indexPath];
    [cell configWithAsset:asset];
    if (asset.isSelected) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToMultiSelectPhotos:)];
    if (![cell.gestureRecognizers containsObject:longPress]) {
        [cell addGestureRecognizer:longPress];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self.drawBoxDC selectAssetAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.drawBoxDC deselectAssetAtIndexPath:indexPath];
}

#pragma mark - Event handling
- (void)longPressToMultiSelectPhotos:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;
    
    if (!self.collectionViewAllowsSelection) {
        self.collectionViewAllowsSelection = YES;
    }
    
    KLAlbumCell *cell = (id)recognizer.view;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    PHAsset *asset = [self.drawBoxDC objectAtIndexPath:indexPath];
    if (asset.isSelected) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
    } else {
        [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
    }
}

- (void)tapRightNavBarButton:(UIBarButtonItem *)sender
{
    if (sender.title.length) {
        [self startDrawFromPhotoVC];
    } else {
        [self deleteSelectedDrawBoxPhotos];
    }
}

- (void)startDrawFromPhotoVC
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        if (self.parentViewController.dismissBlock) {
            self.parentViewController.dismissBlock();
        }
    }];
}

- (void)deleteSelectedDrawBoxPhotos
{
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:BUTTON_TITLE_CANCEL style:UIAlertActionStyleCancel handler:nil];
    NSString *title = [NSString localizedStringWithFormat:BUTTON_TITLE_DELETE_PHOTO_COUNT, self.drawBoxDC.selectedAssetCount];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self.drawBoxDC deleteSelectedAssets];
        if (self.dismissBlock) {
            self.dismissBlock();
        }
    }];
    [[UIAlertController actionSheetControllerWithActions:@[delete, cancel]] show];
}

- (void)cancelMultiPhotoSelection:(id)sender
{
    self.collectionViewAllowsSelection = NO;
    [self.drawBoxDC clearSelection];
}

- (void)setCollectionViewAllowsSelection:(BOOL)collectionViewAllowsSelection
{
    _collectionViewAllowsSelection = collectionViewAllowsSelection;
    self.collectionView.allowsSelection = collectionViewAllowsSelection;
    self.collectionView.allowsMultipleSelection = collectionViewAllowsSelection;
    
    if (collectionViewAllowsSelection) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelMultiPhotoSelection:)];
        self.navigationItem.rightBarButtonItem.title = nil;
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_delete"];
        
        [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(KLAlbumCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            [cell animateSpringScale];
        }];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem.title = BUTTON_TITLE_START;
        self.navigationItem.rightBarButtonItem.image = nil;
    }
}

@end
