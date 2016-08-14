//
//  KLDrawPoolViewController.m
//  Raffle
//
//  Created by Killua Liu on 7/30/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawPoolViewController.h"
#import "KLDrawPoolCell.h"
#import "KLCircleLayout.h"

@interface KLDrawPoolViewController ()

@property (nonatomic, strong) KLDrawPoolViewModel *viewModel;

@end

@implementation KLDrawPoolViewController

#pragma mark - Life cycle
+ (instancetype)viewControllerWithPageIndex:(NSInteger)pageIndex viewModel:(KLDrawPoolViewModel *)viewModel
{
    return [[self alloc] initWithPageIndex:pageIndex viewModel:viewModel];
}

- (instancetype)initWithPageIndex:(NSInteger)pageIndex viewModel:(KLDrawPoolViewModel *)viewModel
{
    if (self = [super initWithCollectionViewLayout:[KLCircleLayout new]]) {
        _pageIndex = pageIndex;
        _viewModel = viewModel;
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
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewModel.photoCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KLDrawPoolCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    [cell configWithAsset:[self.viewModel assetAtIndex:indexPath.item]];
    
    return cell;
}

#pragma mark - Event handling
- (void)startDraw:(id)sender
{
    
}

- (void)stopDraw:(id)sender
{
    
}

- (void)shakeToStart:(id)sender
{
    
}

@end
