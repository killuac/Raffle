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

@property (nonatomic, strong) NSMutableArray<NSString *> *imageNames;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *imageDict;   // All images selection state, default NO.

@end

@implementation KLWallpaperViewController

static CGSize cellItemSize;
static CGFloat lineSpacing;

+ (void)load
{
    lineSpacing = IS_PAD ? 32 : 16;
    cellItemSize = CGSizeMake(120, 240);
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
    self.title = TITLE_CHOOSE_WALLPAPER;
    self.navigationBar.barTintColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = cellItemSize;
    flowLayout.minimumLineSpacing = lineSpacing;
    flowLayout.minimumInteritemSpacing = lineSpacing;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.collectionView registerClass:[KLPhotoCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
}

- (void)viewDidLayoutSubviews
{
    self.navigationController.view.superview.layer.cornerRadius = 0;
    [self.navigationController.view.superview setCornerRadius:10 byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
}

#pragma mark - UICollectionViewDataSource
- (NSMutableArray<NSString *> *)imageNames
{
    if (_imageNames) return _imageNames;
    
    NSUInteger count = DEFAULT_WALLPAPER_COUNT;
    _imageNames = [NSMutableArray arrayWithCapacity:count];
    _imageDict = [NSMutableDictionary dictionaryWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        NSString *imageName = [NSString stringWithFormat:@"wallpaper%tu.jpg", i];
        [_imageNames addObject:imageName];
        
        BOOL selected = [imageName isEqualToString:self.selectedImageName];
        [_imageDict setObject:@(selected) forKey:imageName];
    }
    return _imageNames;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageNames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KLPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    NSString *imageName = self.imageNames[indexPath.item];
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.selected = self.imageDict[imageName].boolValue;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *imageName = self.imageNames[indexPath.item];
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(wallpaperViewController:didChooseWallpaperImageName:)]) {
            [self.delegate wallpaperViewController:self didChooseWallpaperImageName:imageName];
        }
    }];
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
