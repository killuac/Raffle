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

@property (nonatomic, readonly) UIView *containerView;

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
    self.navigationBar.barTintColor = UIColor.whiteColor;
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = cellItemSize;
    flowLayout.minimumLineSpacing = lineSpacing;
    flowLayout.minimumInteritemSpacing = lineSpacing;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView.contentInset = UIEdgeInsetsMake(0, lineSpacing, 0, lineSpacing);
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.collectionView registerClass:[KLPhotoCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
}

- (UIView *)containerView
{
    return self.navigationController.presentationController.containerView;;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.containerView.transform = CGAffineTransformMakeTranslation(0, self.containerView.height);
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [UIView animateWithDuration:0.4 delay:0 options:0 animations:^{
        self.containerView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [UIView animateWithDuration:0.4 delay:0 options:0 animations:^{
        self.containerView.transform = CGAffineTransformMakeTranslation(0, self.containerView.height/2);
    } completion:nil];
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
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.layer.borderWidth = 0;
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.selected = self.imageDict[imageName].boolValue;
    cell.userInteractionEnabled = !cell.isSelected;
    
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
