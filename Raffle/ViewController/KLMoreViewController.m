//
//  KLMoreViewController.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLMoreViewController.h"

const CGFloat KLMoreViewControllerLineSpacing = 20.0;

@interface KLMoreViewController ()

@end

@implementation KLMoreViewController

static CGSize cellItemSize;

+ (void)load
{
    CGFloat width, height;
    width = height = (SCREEN_WIDTH - KLMoreViewControllerLineSpacing * 3) / 2;
    cellItemSize = CGSizeMake(width, height);
}

+ (instancetype)viewController
{
    return [[self alloc] initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
}

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
}

- (void)prepareForUI
{
    self.title = TITLE_DRAW_BOX;
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImageName:@"button_close" target:self action:@selector(closeMoreDrawBoxes:)];
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = cellItemSize;
    flowLayout.minimumLineSpacing = KLMoreViewControllerLineSpacing;
    flowLayout.minimumInteritemSpacing = KLMoreViewControllerLineSpacing;
    
    self.collectionView.backgroundColor = [UIColor darkBackgroundColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
}

#pragma mark - Table view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    return cell;
}

#pragma mark - Event handling
- (void)closeMoreDrawBoxes:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
