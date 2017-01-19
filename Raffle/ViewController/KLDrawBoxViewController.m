//
//  KLDrawBoxViewController.m
//  Raffle
//
//  Created by Killua Liu on 7/30/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawBoxViewController.h"
#import "KLMainViewController.h"
#import "KLDrawBoxDataController.h"
#import "KLWallpaperViewController.h"

@interface KLDrawBoxViewController () <KLDataControllerDelegate, UIPopoverPresentationControllerDelegate, KLWallpaperViewControllerDelegate>

@property (nonatomic, strong) KLMainDataController *mainDC;
@property (nonatomic, weak, readonly) KLMainViewController *mainVC;

@property (nonatomic, strong) UIImageView *bgImageView;

@end

@implementation KLDrawBoxViewController

#pragma mark - Lifecycle
+ (instancetype)viewControllerWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex
{
    return [[self alloc] initWithDataController:dataController atPageIndex:pageIndex];
}

- (instancetype)initWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex
{
    if (self = [super init]) {
        _mainDC = dataController;
        _dataController = [dataController drawBoxDataControllerAtIndex:pageIndex];
        _dataController.delegate = self;
    }
    return self;
}

- (NSUInteger)pageIndex
{
    return self.dataController.pageIndex;
}

- (KLMainViewController *)mainVC
{
    return (id)self.parentViewController.parentViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
    [self reloadData];
    [self addObservers];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addObservers];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeObservers];
}

- (void)prepareForUI
{
    [self addSubviews];
}

- (void)addSubviews
{
    [self.view addSubview:({
        _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bgImageView.alpha = 0.7;
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _bgImageView;
    })];
    
    [self updateWallpaperAnimated:NO];
}

- (void)updateWallpaperAnimated:(BOOL)animated
{
    NSArray<UIView *> *oldSliceViews;
    if (animated) {
        oldSliceViews = [self createSliceViews];
        [oldSliceViews enumerateObjectsUsingBlock:^(UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.view addSubview:view];
        }];
    }
    
    if (self.dataController.hasCustomWallpaper) {
        self.bgImageView.image = [UIImage imageWithContentsOfFile:self.dataController.wallpaperFilePath];
    } else {
        self.bgImageView.image = [UIImage imageNamed:self.dataController.wallpaperName];
    }
    
    if (!animated) return;
    
    NSArray<UIView *> *newSliceViews = [self createSliceViews];
    [self repositionSliceViews:newSliceViews fromUp:NO];
    [newSliceViews enumerateObjectsUsingBlock:^(UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.view addSubview:view];
    }];
    
    self.bgImageView.hidden = YES;
    [UIView animateWithDuration:2 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self repositionSliceViews:oldSliceViews fromUp:YES];
        [self resetYForSliceViews:newSliceViews];
    } completion:^(BOOL finished) {
        self.bgImageView.hidden = NO;
        [oldSliceViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [newSliceViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
}

#pragma mark - Change wallpaper animation
- (NSArray *)createSliceViews
{
    CGFloat sliceWidth = 5.0;
    UIView *view = [self.bgImageView snapshotViewAfterScreenUpdates:YES];
    NSMutableArray *sliceViews = [NSMutableArray array];
    
    for (NSUInteger x = 0; x < self.view.width; x += sliceWidth) {
        CGRect rect = CGRectMake(x, 0, sliceWidth, view.height);
        UIView *sliceView = [view resizableSnapshotViewFromRect:rect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        sliceView.frame = rect;
        [sliceViews addObject:sliceView];
    }
    
    return sliceViews;
}

- (void)repositionSliceViews:(NSArray *)sliceViews fromUp:(BOOL)fromUp
{
    CGFloat height;
    BOOL isFromUp = fromUp;
    for (UIView *sliceView in sliceViews) {
        height = sliceView.height * KLRandomFloat(1.0, 4.0);
        sliceView.top += isFromUp ? -height : height;
        isFromUp = !isFromUp;
    }
}

- (void)resetYForSliceViews:(NSArray *)sliceViews
{
    [sliceViews setValue:@(self.view.top) forKey:@"top"];
}

#pragma mark - Observers
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    self.KVOController = [FBKVOController controllerWithObserver:self];
    [self.KVOController observe:self.dataController keyPath:NSStringFromSelector(@selector(remainingAssetCount)) options:0 action:@selector(updateAddPhotoButtonTitle)];
}

- (void)updateAddPhotoButtonTitle
{
    [self.mainVC updateAddPhotoButtonTitle];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientationDidChange:(NSNotification *)notification
{
    [self reloadData];
}

- (void)reloadData
{
    [self layoutPhotos];
    [self updateAddPhotoButtonTitle];
}

#pragma mark - Random photos
- (void)layoutPhotos
{
    // TODO: layoutPhotos
}

#pragma mark - Data controller delegate
- (void)controllerDidChangeContent:(KLDataController *)controller
{
    [self reloadData];
    [self updateWallpaperAnimated:YES];
}

- (void)controller:(KLDataController *)controller didChangeAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths forChangeType:(KLDataChangeType)type
{
    [self reloadData];
}

#pragma mark - Image picker and camera delegate
- (void)imagePickerController:(KLImagePickerController *)picker didFinishPickingImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.dataController addPhotos:assets completion:nil];
}

- (void)cameraViewController:(KLCameraViewController *)cameraVC didFinishSaveImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.dataController addPhotos:assets completion:nil];
}

#pragma mark - Choose wallpaper
const CGFloat popoverContentHeight = 280;

- (void)showWallpaperViewController
{
    KLWallpaperViewController *wallpaperVC = [KLWallpaperViewController viewController];
    wallpaperVC.delegate = self;
    wallpaperVC.selectedImageName = self.dataController.wallpaperName;
    
    UINavigationController *navController = [[UINavigationController alloc]  initWithRootViewController:wallpaperVC];
    navController.modalPresentationStyle = UIModalPresentationPopover;
    navController.preferredContentSize = CGSizeMake(self.view.width, popoverContentHeight);
    navController.popoverPresentationController.delegate = self;
    navController.popoverPresentationController.permittedArrowDirections = kNilOptions;
    navController.popoverPresentationController.popoverBackgroundViewClass = [KLWallpaperPopoverBackgroundView class];
    navController.popoverPresentationController.sourceView = self.view;
    navController.popoverPresentationController.sourceRect = CGRectMake(0, self.view.bottom, 0, 0);
    [self presentViewController:navController animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView  * __nonnull * __nonnull)view;
{
    *rect = CGRectMake(0, self.view.bottom, self.view.width, popoverContentHeight);
}

#pragma mark - KLWallpaperViewControllerDelegate
- (void)wallpaperViewController:(KLWallpaperViewController *)wallpaperVC didChooseWallpaperImageName:(NSString *)imageName
{
    [self.dataController changeWallpaperWithImageName:imageName];
}

@end
