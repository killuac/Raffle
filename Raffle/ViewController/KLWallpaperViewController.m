//
//  KLWallpaperViewController.m
//  Raffle
//
//  Created by Killua Liu on 1/11/17.
//  Copyright © 2017 Syzygy. All rights reserved.
//

#import "KLWallpaperViewController.h"
#import "KLPhotoCell.h"

@interface KLWallpaperViewController ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation KLWallpaperViewController

static CGSize cellItemSize;
static CGFloat lineSpacing;

+ (void)load
{
    lineSpacing = IS_PAD ? 16 : 8;
    cellItemSize = CGSizeMake(90, 270);
}

#pragma mark - Lifecycle
- (instancetype)init
{
    return [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
}

- (void)prepareForUI
{
    self.view.backgroundColor = [UIColor darkBackgroundColor];
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = cellItemSize;
    flowLayout.minimumLineSpacing = lineSpacing;
    flowLayout.minimumInteritemSpacing = lineSpacing;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.collectionView registerClass:[KLPhotoCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KLPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(wallpaperViewController:didChooseWallpaperImageName:)]) {
        [self.delegate wallpaperViewController:self didChooseWallpaperImageName:nil];
    }
}

@end


#pragma mark - KLWallpaperPopoverBackgroundView
#pragma mark -
@implementation KLWallpaperPopoverBackgroundView

+ (BOOL)wantsDefaultContentAppearance
{
    return NO;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(0, -10, -10, -10);
}

+ (CGFloat)arrowHeight { return 0; }
- (void)setArrowOffset:(CGFloat)arrowOffset { }
- (UIPopoverArrowDirection)arrowDirection { return kNilOptions; }

@end
