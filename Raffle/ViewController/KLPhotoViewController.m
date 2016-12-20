//
//  KLPhotoViewController.m
//  Raffle
//
//  Created by Killua Liu on 9/19/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLPhotoViewController.h"
#import "KLAlbumCell.h"
#import "KLAddButtonCell.h"
#import "KLDrawBoxTransition.h"
#import "KLDrawBoxDataController.h"
#import "KLImagePickerController.h"

NSNotificationName const KLPhotoViewControllerDidTouchStart = @"KLPhotoViewControllerDidTouchStart";

@interface KLPhotoViewController () <KLDataControllerDelegate, KLImagePickerControllerDelegate>

@property (nonatomic, strong) KLDrawBoxDataController *drawBoxDC;
@property (nonatomic, assign, getter=isDeleteMode) BOOL deleteMode;

@end

@implementation KLPhotoViewController

static CGSize CellItemSize;
static CGFloat LineSpacing;

+ (void)load
{
    CGFloat width, height;
    LineSpacing = IS_PAD ? 12 : 3;
    NSUInteger columnCount = IS_PAD ? 5 : 4;
    NSUInteger spacingCount = IS_PAD ? columnCount + 1 : columnCount - 1;
    width = height = (SCREEN_WIDTH - LineSpacing * spacingCount) / columnCount;
    CellItemSize = CGSizeMake(width, height);
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
        _drawBoxDC.delegate = self;
        self.transitioningDelegate = [KLDrawBoxTransition transition];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
}

- (void)prepareForUI
{
    self.title = TITLE_DRAW_BOX;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithTitle:BUTTON_TITLE_START target:self action:@selector(tapRightNavBarButton:)];
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = CellItemSize;
    flowLayout.minimumLineSpacing = LineSpacing;
    flowLayout.minimumInteritemSpacing = LineSpacing;
    
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.backgroundColor = [UIColor darkBackgroundColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.collectionView.contentInset = IS_PAD ? UIEdgeInsetsMake(LineSpacing, LineSpacing, LineSpacing, LineSpacing) : UIEdgeInsetsMake(2, 0, 2, 0);
    [self.collectionView registerClass:[KLAlbumCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
    [self.collectionView registerClass:[KLAddButtonCell class] forCellWithReuseIdentifier:NSStringFromClass([KLAddButtonCell class])];
}

- (void)dealloc
{
    if (self.drawBoxDC.itemCount == 0 && self.dismissBlock) {
        self.dismissBlock(self.drawBoxDC);  // Need remove draw box which in there is no photo
    }
}

- (void)reloadData
{
    if (self.drawBoxDC.itemCount > 0) {
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.drawBoxDC.itemCount + 1;    // Last cell is "Add Button"
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.drawBoxDC.itemCount) {  // Add Button
        KLAddButtonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([KLAddButtonCell class]) forIndexPath:indexPath];
        [cell setHidden:self.deleteMode animated:YES];
        return cell;
    } else {
        KLAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
        PHAsset *asset = [self.drawBoxDC objectAtIndexPath:indexPath];
        [cell configWithAsset:asset];
        if (asset.isSelected) [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToMultiSelectPhotos:)];
        if (![cell.gestureRecognizers containsObject:longPress]) {
            [cell addGestureRecognizer:longPress];
        }
        return cell;
    }
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.item == self.drawBoxDC.itemCount) ? YES : self.deleteMode;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.item == self.drawBoxDC.itemCount) ? YES : self.deleteMode;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.item == self.drawBoxDC.itemCount) {   // Add Button
        [KLImagePickerController checkAuthorization:^{
            KLImagePickerController *imagePicker = [KLImagePickerController imagePickerController];
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }];
    } else if (self.deleteMode) {
        [self.drawBoxDC selectAssetAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.drawBoxDC deselectAssetAtIndexPath:indexPath];
}

#pragma mark - Data controller delegate
- (void)controllerDidChangeSelection:(KLDataController *)controller
{
    // Only if right bar button is "Delete" icon, need check enablement.
    if (self.isDeleteMode) {
        self.navigationItem.rightBarButtonItem.enabled = self.drawBoxDC.selectedAssetCount > 0;
    }
}

- (void)controllerDidChangeContent:(KLDataController *)controller
{
    [self updateUI];
    [self reloadData];
}

- (void)controller:(KLDataController *)controller didChangeAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths forChangeType:(KLDataChangeType)type
{
    [self updateUI];
    
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

- (void)updateUI
{
    if (self.deleteMode && self.drawBoxDC.itemCount == 0) {
        [self cancelMultiPhotoSelection:nil];
        KLDispatchMainAfter(0.5, ^{
            [self.collectionView reloadData];   // Delay for display "Add Button"
        });
    }
}

#pragma mark - KLImagePickerController delegate
- (void)imagePickerController:(KLImagePickerController *)picker didFinishPickingImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.drawBoxDC addPhotos:assets completion:nil];
}

#pragma mark - Event handling
- (void)longPressToMultiSelectPhotos:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;
    
    if (!self.deleteMode) {
        self.deleteMode = YES;
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
    [self reloadData];
}

- (void)tapRightNavBarButton:(UIBarButtonItem *)sender
{
    if (self.deleteMode) {
        [self deleteSelectedDrawBoxPhotos];
    } else {
        [self startDrawFromPhotoVC];
    }
}

- (void)startDrawFromPhotoVC
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KLPhotoViewControllerDidTouchStart object:self.drawBoxDC];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteSelectedDrawBoxPhotos
{
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:BUTTON_TITLE_CANCEL style:UIAlertActionStyleCancel handler:nil];
    NSUInteger count = self.drawBoxDC.selectedAssetCount;
    NSString *title = count > 1 ? [NSString stringWithFormat:BUTTON_TITLE_DELETE_PHOTO_COUNT_OTHER, count] : BUTTON_TITLE_DELETE_PHOTO_COUNT_ONE;
    UIAlertAction *delete = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self.drawBoxDC deleteSelectedAssets];
    }];
    
    UIAlertController *alertController = [UIAlertController actionSheetControllerWithActions:@[delete, cancel]];
    alertController.popoverPresentationController.sourceView = self.view;
    alertController.popoverPresentationController.sourceRect = self.navigationBar.frame;
    [alertController show];
}

- (void)cancelMultiPhotoSelection:(id)sender
{
    self.deleteMode = NO;
    [self.drawBoxDC clearSelection];
    [self reloadData];
    self.navigationItem.rightBarButtonItem.enabled = self.drawBoxDC.itemCount > 0;
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
        self.navigationItem.rightBarButtonItem.title = BUTTON_TITLE_START;
        self.navigationItem.rightBarButtonItem.image = nil;
    }
}

@end
