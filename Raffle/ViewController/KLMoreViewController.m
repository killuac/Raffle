//
//  KLMoreViewController.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLMoreViewController.h"
#import "KLMainDataController.h"
#import "KLDrawBoxCell.h"
#import "KLAddButtonCell.h"
#import "KLPhotoViewController.h"
#import "KLImagePickerController.h"

@interface KLMoreViewController () <KLDataControllerDelegate, KLImagePickerControllerDelegate, KLCameraViewControllerDelegate>

@property (nonatomic, strong) KLMainDataController *dataController;
@property (nonatomic, weak) id <KLDataControllerDelegate> previousDelegate;     // Main view controller

@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, assign) BOOL editMode;

@end

@implementation KLMoreViewController

static CGSize cellItemSize;
static CGFloat sectionInset;

+ (void)load
{
    CGFloat width, height;
    sectionInset = IS_PAD ? 16 : 8;
    NSUInteger columnCount = IS_PAD ? 4 : 3;
    width = height = (SCREEN_WIDTH - sectionInset * 2 * (columnCount + 1)) / columnCount;
    cellItemSize = CGSizeMake(width, height);
}

#pragma mark - Lifecycle
- (instancetype)initWithDataController:(KLMainDataController *)dataController
{
    // Overwirte delegate, so need save previous delegate (KLMainViewController).
    if (self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]]) {
        self.previousDelegate = dataController.delegate;
        _dataController = dataController;
        _dataController.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.dataController.delegate = self.previousDelegate;   // Avoid free in advance
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
}

- (void)prepareForUI
{
    self.title = TITLE_DRAW_BOXES;
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.backBarButtonItem = [UIBarButtonItem backBarButtonItem];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImageName:@"icon_close" target:self action:@selector(closeMoreDrawBoxes:)];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = self.dataController.itemCount > 0;
    self.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
    
    self.view.backgroundColor = UIColor.darkBackgroundColor;
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = cellItemSize;
    flowLayout.sectionInset = UIEdgeInsetsMake(sectionInset, sectionInset, sectionInset, sectionInset);
    
    self.collectionView.contentInset = flowLayout.sectionInset;
    self.collectionView.backgroundColor = self.view.backgroundColor;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.collectionView registerClass:[KLDrawBoxCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
    [self.collectionView registerClass:[KLAddButtonCell class] forCellWithReuseIdentifier:NSStringFromClass([KLAddButtonCell class])];
}

- (void)reloadData
{
    if (self.dataController.itemCount > 0) {
        [self.collectionView reloadData];
    }
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataController.itemCount + 1;   // Last cell is "Add Button"
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.dataController.itemCount) {  // Add Button
        KLAddButtonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([KLAddButtonCell class]) forIndexPath:indexPath];
        [cell setAnimatedHidden:self.editMode completion:nil];
        return cell;
    } else {
        KLDrawBoxCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
        [cell configWithDrawBox:[self.dataController objectAtIndexPath:indexPath] editMode:self.editMode];
        if (![cell.deleteButton.allTargets containsObject:self]) {
            [cell.deleteButton addTarget:self action:@selector(deleteDrawBox:)];
        }
        return cell;
    }
}

#pragma mark - Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.dataController.itemCount) {  // Add Button
        [self showImagePickerControllerFromMoreVC];
    } else {
        [self showPhotoViewControllerAtIndexPath:indexPath];
    }
}

- (void)showImagePickerControllerFromMoreVC
{
    [KLImagePickerController checkAuthorization:^{
        KLImagePickerController *imagePicker = [KLImagePickerController imagePickerController];
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
}

- (void)showPhotoViewControllerAtIndexPath:(NSIndexPath *)indexPath
{
    KLDrawBoxDataController *drawBoxDC = [self.dataController drawBoxDataControllerAtIndex:indexPath.item];
    KLPhotoViewController *photoVC = [KLPhotoViewController viewControllerWithDataController:drawBoxDC];
//  TODO: self.navigationController.delegate = photoVC.transition;
    [self.navigationController pushViewController:photoVC animated:YES];
    
    photoVC.dismissBlock = ^(KLDrawBoxDataController *drawBoxDC) {
        [self.dataController deleteDrawBoxAtIndexPath:indexPath];
    };
}

#pragma mark - Data controller delegate
- (void)controllerDidChangeContent:(KLDataController *)controller
{
    [self checkRightBarButtonEnablement];
    [self reloadData];
    
    if ([self.previousDelegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
        [self.previousDelegate controllerDidChangeContent:controller];
    }
}

- (void)controller:(KLDataController *)controller didChangeAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths forChangeType:(KLDataChangeType)type
{
    [self checkRightBarButtonEnablement];
    
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

- (void)checkRightBarButtonEnablement
{
    self.navigationItem.rightBarButtonItem.enabled = self.dataController.itemCount > 0;
    if (self.editMode && self.dataController.itemCount == 0) {
        [self setEditing:NO animated:YES];
        KLDispatchMainAfter(0.5, ^{
            [self.collectionView reloadData];   // Delay for display "Add Button"
        });
    }
}

#pragma mark - Image picker and camera delegate
- (void)imagePickerController:(KLImagePickerController *)picker didFinishPickingImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.dataController addDrawBoxWithAssets:assets];
}

- (void)cameraViewController:(KLCameraViewController *)cameraVC didFinishSaveImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.dataController addDrawBoxWithAssets:assets];
}

#pragma mark - Event handling
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self editMoreDrawBoxes];
}

- (void)editMoreDrawBoxes
{
    self.editMode = !self.editMode;
    self.navigationItem.leftBarButtonItem = self.editMode ? nil : self.leftBarButtonItem;
    self.collectionView.allowsSelection = !self.editMode;
    [self reloadData];
}

- (void)deleteDrawBox:(UIButton *)button
{
    KLDrawBoxCell *cell = (id)button.superCollectionViewCell;
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TITLE_CANCEL style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:TITLE_DELETE_DRAW_BOX style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        [self.dataController deleteDrawBoxAtIndexPath:indexPath];
    }];
    
    UIAlertController *alertController = [UIAlertController actionSheetControllerWithActions:@[delete, cancel]];
    alertController.popoverPresentationController.sourceView = self.view;
    CGPoint position = CGPointMake(button.left + button.width/2, button.bottom);
    CGPoint sourcePosition = [cell convertPoint:position toView:self.view];
    alertController.popoverPresentationController.sourceRect = (CGRect){sourcePosition, CGSizeZero};
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    [alertController show];
}

- (void)closeMoreDrawBoxes:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
