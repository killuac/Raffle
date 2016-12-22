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
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithSystemItem:UIBarButtonSystemItemDone target:self action:@selector(useFaceDetectedImages:)];
    
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

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    // Configure the cell
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

#pragma mark - Event handing
- (void)backFromFaceVC:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)useFaceDetectedImages:(id)sender
{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
