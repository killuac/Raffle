//
//  KLPhotoViewController.m
//  Raffle
//
//  Created by Killua Liu on 9/19/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLPhotoViewController.h"
#import "KLPhotoCell.h"
#import "KLAddButtonCell.h"
#import "KLDrawBoxTransition.h"
#import "KLDrawBoxDataController.h"
#import "KLImagePickerController.h"

NSNotificationName const KLPhotoViewControllerDidTouchStart = @"KLPhotoViewControllerDidTouchStart";

@interface KLPhotoViewController () <KLDataControllerDelegate, KLImagePickerControllerDelegate, KLCameraViewControllerDelegate>

@property (nonatomic, strong) KLDrawBoxDataController *dataController;
@property (nonatomic, weak) id <KLDataControllerDelegate> previousDelegate;     // draw box view controller

@property (nonatomic, assign, getter=isDeleteMode) BOOL deleteMode;

@end

@implementation KLPhotoViewController

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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Lifecycle
- (instancetype)initWithDataController:(KLDrawBoxDataController *)dataController
{
    if (self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]]) {
        self.previousDelegate = dataController.delegate;
        _dataController = dataController;
        _dataController.delegate = self;
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
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithTitle:TITLE_START target:self action:@selector(tapRightNavBarButton:)];
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = cellItemSize;
    flowLayout.minimumLineSpacing = lineSpacing;
    flowLayout.minimumInteritemSpacing = lineSpacing;
    
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.backgroundColor = UIColor.darkBackgroundColor;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.collectionView.contentInset = IS_PAD ? UIEdgeInsetsMake(lineSpacing, lineSpacing, lineSpacing, lineSpacing) : UIEdgeInsetsMake(2, 0, 2, 0);
    [self.collectionView registerClass:[KLPhotoCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
    [self.collectionView registerClass:[KLAddButtonCell class] forCellWithReuseIdentifier:NSStringFromClass([KLAddButtonCell class])];
}

- (void)dealloc
{
    if (self.dataController.itemCount == 0 && self.dismissBlock) {
        self.dismissBlock(self.dataController);  // Need remove draw box which in there is no photo
    }
    self.dataController.delegate = self.previousDelegate;   // Avoid free in advance
}

- (void)reloadData
{
    if (self.dataController.itemCount > 0) {
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataController.itemCount + 1;    // Last cell is "Add Button"
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.dataController.itemCount) {  // Add Button
        KLAddButtonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([KLAddButtonCell class]) forIndexPath:indexPath];
        [cell setAnimatedHidden:self.deleteMode completion:nil];
        return cell;
    } else {
        KLPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
        cell.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToMultiSelectPhotos:)];
        [cell configWithAsset:[self.dataController objectAtIndexPath:indexPath]];
        return cell;
    }
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.item == self.dataController.itemCount) ? YES : self.deleteMode;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.item == self.dataController.itemCount) ? YES : self.deleteMode;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.item == self.dataController.itemCount) {   // Add Button
        [self showImagePickerControllerFromPhotoVC];
    } else if (self.deleteMode) {
        [self.dataController selectAssetAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.dataController deselectAssetAtIndexPath:indexPath];
}

- (void)showImagePickerControllerFromPhotoVC
{
    [KLImagePickerController checkAuthorization:^{
        KLImagePickerController *imagePicker = [KLImagePickerController imagePickerController];
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
}

#pragma mark - Data controller delegate
- (void)controllerDidChangeSelection:(KLDataController *)controller
{
    [self updateUI];
}

- (void)controllerDidChangeContent:(KLDataController *)controller
{
    [self updateUI];
    [self reloadData];
    
    if ([self.previousDelegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
        [self.previousDelegate controllerDidChangeContent:controller];
    }
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
    
    if ([self.previousDelegate respondsToSelector:@selector(controller:didChangeAtIndexPaths:forChangeType:)]) {
        [self.previousDelegate controller:controller didChangeAtIndexPaths:indexPaths forChangeType:type];
    }
}

- (void)updateUI
{
    // Only if right bar button is "Delete" icon, need check enablement.
    if (self.isDeleteMode) {
        self.navigationItem.rightBarButtonItem.enabled = self.dataController.selectedAssetCount > 0;
    }
    
    if (self.isDeleteMode && self.dataController.itemCount == 0) {
        [self cancelMultiPhotoSelection:nil];
        KLDispatchMainAfter(0.5, ^{
            [self.collectionView reloadData];   // Delay for display "Add Button"
        });
    }
}

#pragma mark - KLImagePickerController delegate
- (void)imagePickerController:(KLImagePickerController *)picker didFinishPickingImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.dataController addPhotos:assets completion:nil];
}

#pragma mark - KLCameraViewController delegate
- (void)cameraViewController:(KLCameraViewController *)cameraVC didFinishSaveImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.dataController addPhotos:assets completion:nil];
}

#pragma mark - Event handling
- (void)longPressToMultiSelectPhotos:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;
    
    self.deleteMode = YES;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(id)recognizer.view];
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
    
    KLAddButtonCell *cell = (id)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataController.itemCount inSection:0]];
    [cell setAnimatedHidden:YES completion:nil];
}

- (void)tapRightNavBarButton:(UIBarButtonItem *)sender
{
    if (self.deleteMode) {
        [self deleteSelectedDrawBoxPhotos:sender];
    } else {
        [self startDrawFromPhotoVC:sender];
    }
}

- (void)startDrawFromPhotoVC:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KLPhotoViewControllerDidTouchStart object:self.dataController];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteSelectedDrawBoxPhotos:(id)sender
{
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TITLE_CANCEL style:UIAlertActionStyleCancel handler:nil];
    NSUInteger count = self.dataController.selectedAssetCount;
    NSString *title = count > 1 ? [NSString stringWithFormat:TITLE_DELETE_PHOTO_COUNT_OTHER, count] : TITLE_DELETE_PHOTO_COUNT_ONE;
    UIAlertAction *delete = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self.dataController deleteSelectedAssets];
    }];
    
    UIAlertController *alertController = [UIAlertController actionSheetControllerWithActions:@[delete, cancel]];
    alertController.popoverPresentationController.sourceView = self.view;
    alertController.popoverPresentationController.sourceRect = self.navigationBar.frame;
    [alertController show];
}

- (void)cancelMultiPhotoSelection:(id)sender
{
    self.deleteMode = NO;
    self.navigationItem.rightBarButtonItem.enabled = self.dataController.itemCount > 0;
    [self.dataController clearSelection];
    [self reloadData];
}

- (void)setDeleteMode:(BOOL)deleteMode
{
    _deleteMode = deleteMode;
    self.collectionView.allowsMultipleSelection = deleteMode;
    
    if (deleteMode) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelMultiPhotoSelection:)];
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_delete"];
        self.navigationItem.rightBarButtonItem.title = nil;
        
        [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(KLPhotoCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
            [cell animateSpringScale];
        }];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem.title = TITLE_START;
        self.navigationItem.rightBarButtonItem.image = nil;
    }
}

@end
