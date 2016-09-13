//
//  KLDrawPoolViewController.m
//  Raffle
//
//  Created by Killua Liu on 7/30/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawPoolViewController.h"
#import "KLMainViewController.h"
#import "KLDrawPoolCell.h"
#import "KLCircleLayout.h"

@interface KLDrawPoolViewController ()

@property (nonatomic, strong) KLMainDataController *mainDC;
@property (nonatomic, strong) KLDrawPoolDataController *drawPoolDC;

@end

@implementation KLDrawPoolViewController

#pragma mark - Life cycle
+ (instancetype)viewControllerWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex
{
    return [[self alloc] initWithDataController:dataController atPageIndex:pageIndex];
}

- (instancetype)initWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex
{
    if (self = [super initWithCollectionViewLayout:[KLCircleLayout new]]) {
        _mainDC = dataController;
        _drawPoolDC = [dataController drawPoolDataControllerAtIndex:pageIndex];
    }
    return self;
}

- (NSUInteger)pageIndex
{
    return self.drawPoolDC.pageIndex;
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
    return self.drawPoolDC.itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KLDrawPoolCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    [cell configWithAsset:[self.drawPoolDC objectAtIndexPath:indexPath]];
    
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
