//
//  KLAlbumViewController.m
//  Raffle
//
//  Created by Killua Liu on 3/18/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLAlbumViewController.h"
#import "KLAlbumCell.h"
#import "KLCameraPreviewView.h"
#import "KLImagePickerController.h"
#import "KLCameraViewController.h"

@interface KLAlbumViewController ()

@property (nonatomic, strong) KLPhotoLibrary *photoLibrary;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, assign) NSUInteger assetsCount;
@property (nonatomic, readonly) BOOL isShowCameraPreview;

@property (nonatomic, strong) KLCameraPreviewView *cameraPreviewView;
@property (nonatomic, strong) UIButton *cameraButton;

@end

@implementation KLAlbumViewController

static CGSize CellItemSize;
static CGFloat LineSpacing;
static NSString *CameraPreviewCellIdentifier = @"CameraPreviewCellIdentifier";

+ (void)load
{
    CGFloat width, height;
    LineSpacing = IS_PAD ? 12 : 3;
    NSUInteger columnCount = IS_PAD ? 5 : 4;
    NSUInteger spacingCount = IS_PAD ? columnCount + 1 : columnCount - 1;
    width = height = (SCREEN_WIDTH - LineSpacing * spacingCount) / columnCount;
    CellItemSize = CGSizeMake(width, height);
}

#pragma mark - Lifecycle
+ (instancetype)viewControllerWithPhotoLibrary:(KLPhotoLibrary *)photoLibrary atPageIndex:(NSUInteger)pageIndex
{
    return [[self alloc] initWithPhotoLibrary:photoLibrary atPageIndex:pageIndex];
}

- (instancetype)initWithPhotoLibrary:(KLPhotoLibrary *)photoLibrary atPageIndex:(NSUInteger)pageIndex
{
    if (self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]]) {
        _photoLibrary = photoLibrary;
        _pageIndex = pageIndex;
        _assetCollection = [photoLibrary assetCollectionAtIndex:pageIndex];
        _assetsCount = _assetCollection.assets.count;
        
        if (self.isShowCameraPreview) {
            [KLCameraViewController checkAuthorization:^(BOOL granted) {
                self.assetsCount += 1;  // The first cell for camera preview display
            }];
        }
    }
    return self;
}

- (BOOL)isShowCameraPreview
{
    return (self.pageIndex == 0 && [AVCaptureDevice devices].count > 0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addObservers];
    [self.cameraPreviewView startRunning:^{
        self.cameraPreviewView.userInteractionEnabled = YES;
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeObservers];
    [self.cameraPreviewView stopRunning:nil];
}

- (void)prepareForUI
{
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionViewLayout;
    flowLayout.itemSize = CellItemSize;
    flowLayout.minimumLineSpacing = LineSpacing;
    flowLayout.minimumInteritemSpacing = LineSpacing;
    
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.backgroundColor = [UIColor darkBackgroundColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.collectionView.contentInset = IS_PAD ? UIEdgeInsetsMake(LineSpacing, LineSpacing, LineSpacing, LineSpacing) : UIEdgeInsetsMake(2, 0, 2, 0);
    [self.collectionView registerClass:[KLAlbumCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CameraPreviewCellIdentifier];
    
    if (!self.isShowCameraPreview) return;
    
    self.cameraPreviewView = [KLCameraPreviewView newAutoLayoutView];
    self.cameraButton = [UIButton buttonWithImageName:@"icon_camera_block"];
    [self.cameraButton addTarget:self action:@selector(showCameraViewController)];
    [self.cameraPreviewView addSubview:self.cameraButton];
    [self.cameraButton constraintsCenterInSuperview];
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    [KLCameraViewController checkAuthorization:^(BOOL granted) {
        if (granted) {
            self.cameraPreviewView = [KLCameraPreviewView newViewWithSession];
            self.cameraPreviewView.userInteractionEnabled = NO;
        }
        [self.cameraPreviewView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCameraViewController)]];
        if (status == AVAuthorizationStatusNotDetermined) {
            [self.cameraPreviewView startRunning:^{
                [self reloadData];
                self.cameraPreviewView.userInteractionEnabled = YES;
            }];
        }
    }];
}

#pragma mark - Observer
- (void)addObservers
{
    self.KVOController = [FBKVOController controllerWithObserver:self];
    [self.KVOController observe:self.assetCollection keyPath:NSStringFromSelector(@selector(assets)) options:0 action:@selector(reloadData)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidStartRunning:) name:AVCaptureSessionDidStartRunningNotification object:self.cameraPreviewView.session];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadData
{
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];   // Must call it for set content offset working
    
    if (!CGPointEqualToPoint(self.assetCollection.contentOffset, CGPointZero)) {
        [self.collectionView setContentOffset:self.assetCollection.contentOffset];
    }
}

- (void)sessionDidStartRunning:(NSNotification *)notification
{
    KLDispatchMainAsync(^{
        [self.cameraButton removeFromSuperview];
    });
}

- (void)sessionWasInterrupted:(NSNotification *)notification
{
    [self.cameraPreviewView stopRunning:nil];
}

- (void)sessionInterruptionEnded:(NSNotification *)notification
{
    [self.cameraPreviewView startRunning:nil];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isShowCameraPreview && indexPath.item == 0) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CameraPreviewCellIdentifier forIndexPath:indexPath];
        [cell.contentView addSubview:self.cameraPreviewView];
        [self.cameraPreviewView constraintsEqualWithSuperView];
        return cell;
    }
    
    KLAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    PHAsset *asset = [self assetAtIndexPath:indexPath];
    [cell configWithAsset:asset];
    if (asset.isSelected) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    return cell;
}

- (PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = self.isShowCameraPreview ? indexPath.item - 1 : indexPath.item;
    return self.assetCollection.assets[index];
}

- (void)showCameraViewController
{
    [KLCameraViewController checkAuthorization:^(BOOL granted) {
        if (granted) {
            [self.cameraPreviewView stopRunning:^{
                KLCameraViewController *cameraVC = [KLCameraViewController cameraViewControllerWithAlbumImage:self.albumImage];
                cameraVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                cameraVC.delegate = [(id)self.parentViewController delegate];
                [self presentViewController:cameraVC animated:YES completion:nil];
            }];
        } else {
            [KLCameraViewController showAlert];
        }
    }];
}

- (UIImage *)albumImage
{
    UIImage *image = nil;
    if (self.assetsCount > 1) {
        KLAlbumCell *cell = (id)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imageView.image];
        imageView.size = CGSizeMake(40, 40);
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 4;
        imageView.layer.borderWidth = 2;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        UIGraphicsBeginImageContextWithOptions(imageView.size, 0.0,  0.0);
        [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

#pragma mark - UICollectionViewDelegate
//- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.isShowCameraPreview && indexPath.item == 0) {
//        [self.cameraPreviewView startRunning];
//    }
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (self.isShowCameraPreview && indexPath.item == 0) {
//        [self.cameraPreviewView stopRunning];
//    }
//}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isShowCameraPreview && indexPath.item == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (!self.isShowCameraPreview || indexPath.item > 0) {
        [self.photoLibrary selectAsset:[self assetAtIndexPath:indexPath]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isShowCameraPreview || indexPath.item > 0) {
        [self.photoLibrary deselectAsset:[self assetAtIndexPath:indexPath]];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.assetCollection.contentOffset = scrollView.contentOffset;
}

@end
