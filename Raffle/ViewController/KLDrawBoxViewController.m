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
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpToChooseWallpaper:)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipe];
}

- (void)addSubviews
{
    [self.view addSubview:({
        _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bgImageView.alpha = 0.8;
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _bgImageView;
    })];
    
    [self setWallpaper];
}

- (void)setWallpaper
{
    if (self.dataController.hasCustomWallpaper) {
        self.bgImageView.image = [UIImage imageWithContentsOfFile:self.dataController.wallpaperFilePath];
    } else {
        self.bgImageView.image = [UIImage imageNamed:@"wallpaper0.jpg"];
    }
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

#pragma mark - Event handling
- (void)swipeUpToChooseWallpaper:(UISwipeGestureRecognizer *)recognizer
{
    KLWallpaperViewController *wallpaperVC = [KLWallpaperViewController viewController];
    wallpaperVC.delegate = self;
    wallpaperVC.modalPresentationStyle = UIModalPresentationPopover;
    wallpaperVC.preferredContentSize = CGSizeMake(self.view.width, 320);
    wallpaperVC.popoverPresentationController.delegate = self;
    wallpaperVC.popoverPresentationController.permittedArrowDirections = kNilOptions;
    wallpaperVC.popoverPresentationController.popoverBackgroundViewClass = [KLWallpaperPopoverBackgroundView class];
    wallpaperVC.popoverPresentationController.sourceView = self.view;
    wallpaperVC.popoverPresentationController.sourceRect = CGRectMake(0, self.view.bottom, 0, 0);
    [self presentViewController:wallpaperVC animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView  * __nonnull * __nonnull)view;
{
    *rect = CGRectMake(0, self.view.bottom, self.view.width, 320);
}

#pragma mark - KLWallpaperViewControllerDelegate
- (void)wallpaperViewController:(KLWallpaperViewController *)wallpaperVC didChooseWallpaperImageName:(NSString *)imageName
{
    // TODO: Select wallpaper
}

@end
