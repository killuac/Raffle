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
#import "KLPhotoViewController.h"

const CGFloat KLMoreViewControllerSectionInset = 8.0;

@interface KLMoreViewController ()

@property (nonatomic, strong) KLMainDataController *dataController;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, assign) BOOL editMode;

@end

@implementation KLMoreViewController

static CGSize cellItemSize;

+ (void)load
{
    CGFloat width, height;
    width = height = (SCREEN_WIDTH - KLMoreViewControllerSectionInset * 2 * 4) / 3;
    cellItemSize = CGSizeMake(width, height);
}

#pragma mark - Lifecycle
- (instancetype)initWithDataController:(id)dataController
{
    if (self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]]) {
        _dataController = dataController;
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
    self.title = TITLE_DRAW_BOXES;
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.backBarButtonItem = [UIBarButtonItem backBarButtonItem];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImageName:@"icon_close" target:self action:@selector(closeMoreDrawBoxes:)];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = self.dataController.isPageScrollEnabled;
    self.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
    
    CGFloat inset = KLMoreViewControllerSectionInset;
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = cellItemSize;
    flowLayout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    
    self.collectionView.contentInset = flowLayout.sectionInset;
    self.collectionView.backgroundColor = [UIColor darkBackgroundColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.collectionView registerClass:[KLDrawBoxCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
}

#pragma mark - Observer
- (void)addObservers
{
    self.KVOController = [FBKVOController controllerWithObserver:self];
    [self.KVOController observe:self.dataController keyPath:@"drawBoxes" options:0 action:@selector(reloadData)];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataController.itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KLDrawBoxCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    [cell configWithDrawBox:[self.dataController objectAtIndexPath:indexPath] editMode:self.editMode];
    [cell.deleteButton addTarget:self action:@selector(deleteDrawBox:)];
    return cell;
}

#pragma mark - Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    KLPhotoViewController *photoVC = [KLPhotoViewController viewControllerWithDataController:self.dataController.currentDrawBoxDC];
    photoVC.dismissBlock = ^{ [self reloadData]; };
    self.navigationController.delegate = photoVC.transition;
    [self.navigationController pushViewController:photoVC animated:YES];
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
    [self.collectionView reloadData];
}

- (void)deleteDrawBox:(UIButton *)sender
{
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:BUTTON_TITLE_CANCEL style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:BUTTON_TITLE_DELETE_DRAW_BOX style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        KLDrawBoxCell *cell = (id)[sender superCollectionViewCell];
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        [self.dataController deleteDrawBoxAtIndexPath:indexPath];
        
        if (self.dismissBlock) {
            self.dismissBlock();
        }
    }];
    [[UIAlertController actionSheetControllerWithActions:@[delete, cancel]] show];
}

- (void)closeMoreDrawBoxes:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
