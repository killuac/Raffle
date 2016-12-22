//
//  KLImagePickerController.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLImagePickerController.h"
#import "KLSegmentControl.h"
#import "KLScaleTransition.h"
#import "KLCircleTransition.h"

@interface KLImagePickerController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, KLSegmentControlDelegate>

@property (nonatomic, strong) KLPhotoLibrary *photoLibrary;

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) KLSegmentControl *segmentControl;
@property (nonatomic, strong) UINavigationBar *bottomBar;
@property (nonatomic, strong) UINavigationItem *bottomBarItem;

@property (nonatomic, strong) NSLayoutConstraint *scHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *barHeightConstraint;

@end

@implementation KLImagePickerController

#pragma mark - Authorization
+ (void)checkAuthorization:(KLVoidBlockType)completion
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (PHAuthorizationStatusNotDetermined == status) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            // This callback is not on main thread.
            [self checkPhotoLibraryWithStatus:status completion:completion];
        }];
    } else {
        [self checkPhotoLibraryWithStatus:status completion:completion];
    }
}

+ (void)checkPhotoLibraryWithStatus:(NSInteger)status completion:(KLVoidBlockType)completion
{
    dispatch_block_t block = ^{
        if (PHAuthorizationStatusAuthorized == status) {
            if (completion) completion();
        } else {
            [self showAlert];
        }
    };
    
    [NSThread isMainThread] ? block() : KLDispatchMainAsync(block);
}

+ (void)showAlert
{
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:BUTTON_TITLE_CANCEL style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:BUTTON_TITLE_SETTING style:UIAlertActionStyleCancel handler:^(id action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    NSString *message = [NSString localizedStringWithFormat:MSG_ACCESS_PHOTOS_SETTING, [APP_DISPLAY_NAME quotedString], [PATH_PHOTOS_SETTING quotedString]];
    [[UIAlertController alertControllerWithTitle:TITLE_PHOTOS message:message actions:@[setting, cancel]] show];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Lifecycle
+ (instancetype)imagePickerController
{
    return [[self alloc] initWithPhotoLibrary:[KLPhotoLibrary new]];
}

- (instancetype)initWithPhotoLibrary:(KLPhotoLibrary *)photoLibrary
{
    if (self = [super init]) {
        _photoLibrary = photoLibrary;
        self.transition = [KLScaleTransition transitionWithGestureEnabled:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addObservers];
    [self prepareForUI];
}

- (void)prepareForUI
{
    self.view.backgroundColor = [UIColor blackColor];
    [self addPageViewController];
    [self addSubviews];
}

#pragma mark - Observer
- (void)addObservers
{
    self.KVOController = [FBKVOController controllerWithObserver:self];
    [self.KVOController observe:self.photoLibrary keyPath:NSStringFromSelector(@selector(assetCollections)) options:0 action:@selector(reloadData)];
    [self.KVOController observe:self.photoLibrary keyPath:NSStringFromSelector(@selector(selectedAssets)) options:0 action:@selector(selectedAssetsChanged)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)reloadData
{
    self.pageScrollView.scrollEnabled = self.photoLibrary.pageCount > 0;
    
    UIViewController *viewController = [self viewControllerAtPageIndex:self.photoLibrary.currentPageIndex];
    if (viewController) {
        [self.pageViewController setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    } else if (self.pageViewController.childViewControllers.count) {
        [self.pageViewController.childViewControllers makeObjectsPerformSelector:@selector(willMoveToParentViewController:) withObject:nil];
        [self.pageViewController.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.pageViewController.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    }
    
    self.segmentControl.items = self.photoLibrary.segmentTitles;
    [self.segmentControl reloadData];
}

- (void)selectedAssetsChanged
{
    NSUInteger count = self.photoLibrary.selectedAssets.count;
    self.bottomBarItem.title = count ? [NSString localizedStringWithFormat:TITLE_SELECTED_PHOTO_COUNT, count] : nil;
    self.bottomBarItem.rightBarButtonItem.enabled = count > 0;
}

- (void)orientationDidChange:(NSNotification *)notification
{
    [self updateViewConstraints];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews and controllers
- (void)addPageViewController
{
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    self.pageScrollView.delegate = self;
    self.pageViewController.view.backgroundColor = [UIColor darkBackgroundColor];
    self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (UIScrollView *)pageScrollView
{
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:UIScrollView.class]) {
            return (UIScrollView *)view;
        }
    }
    return nil;
}

- (void)addSubviews
{
    [self.view addSubview:({
        _segmentControl = [KLSegmentControl segmentControlWithItems:nil];
        _segmentControl.delegate = self;
        _segmentControl;
    })];
    
    [self.view addSubview:({
        _bottomBarItem = [[UINavigationItem alloc] init];
        _bottomBarItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImageName:@"icon_close" target:self action:@selector(closeAlbum:)];
        _bottomBarItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePhotoSelection:)];
        _bottomBarItem.rightBarButtonItem.enabled = NO;
        
        _bottomBar = [UINavigationBar newAutoLayoutView];
        _bottomBar.barStyle = UIBarStyleBlack;
        _bottomBar.items = @[_bottomBarItem];
        _bottomBar.tintColor = [UIColor whiteColor];
        
        _bottomBar;
    })];
    
    UIView *pageView = self.pageViewController.view;
    NSDictionary *views = NSDictionaryOfVariableBindings(_segmentControl, _bottomBar, pageView);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_segmentControl]|" views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_segmentControl][pageView][_bottomBar]|"
                                                                                    options:NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing views:views]];
    
    self.scHeightConstraint = [NSLayoutConstraint constraintHeightWithItem:_segmentControl constant:0];
    self.barHeightConstraint = [NSLayoutConstraint constraintHeightWithItem:_bottomBar constant:0];
}

- (void)updateViewConstraints
{
    self.scHeightConstraint.active = YES;
    self.scHeightConstraint.constant = self.segmentControl.intrinsicContentHeight;
    
    self.barHeightConstraint.active = YES;
    self.barHeightConstraint.constant = self.bottomBarHeight;
    
    [super updateViewConstraints];
}

- (CGFloat)bottomBarHeight
{
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 44 : 34;
}

#pragma mark - Page view controller datasource and delegate
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(KLAlbumViewController *)viewController
{
    NSUInteger index = viewController.pageIndex;
    if (index == 0 || index == NSNotFound) return nil;
    
    return [self viewControllerAtPageIndex:index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(KLAlbumViewController *)viewController
{
    NSUInteger index = viewController.pageIndex;
    if (index == NSNotFound) return nil;
    
    return [self viewControllerAtPageIndex:index + 1];
}

- (KLAlbumViewController *)viewControllerAtPageIndex:(NSUInteger)index
{
    if (self.photoLibrary.pageCount == 0 || index >= self.photoLibrary.pageCount) return nil;
    
    KLAlbumViewController *albumVC = [KLAlbumViewController viewControllerWithPhotoLibrary:self.photoLibrary atPageIndex:index];
    
    return albumVC;
}

#pragma mark - Scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.width == 0) return;
    CGFloat offsetRate = (scrollView.contentOffset.x - scrollView.width) / scrollView.width;
    [self.segmentControl scrollWithOffsetRate:offsetRate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollToSelectAlbum];
}

- (void)scrollToSelectAlbum
{
    KLAlbumViewController *albumVC = self.pageViewController.viewControllers.firstObject;
    self.photoLibrary.currentPageIndex = albumVC.pageIndex;
    [self.segmentControl selectSegmentAtIndex:albumVC.pageIndex];
}

#pragma mark - Segment control delegate
- (void)segmentControl:(KLSegmentControl *)segmentControl didSelectSegmentAtIndex:(NSUInteger)index
{
    if (self.photoLibrary.currentPageIndex != index) {
        [self selectSegmentControlAtIndex:index];
    }
}

- (void)selectSegmentControlAtIndex:(NSUInteger)index
{
    DECLARE_WEAK_SELF;
    self.photoLibrary.currentPageIndex = index;
    KLAlbumViewController *albumVC = self.pageViewController.viewControllers.firstObject;
    UIPageViewControllerNavigationDirection direction = (albumVC.pageIndex < index) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    
    self.pageScrollView.delegate = nil;
    [self.pageViewController setViewControllers:@[[self viewControllerAtPageIndex:index]] direction:direction animated:YES completion:^(BOOL finished) {
        welf.pageScrollView.delegate = welf;
    }];
}

#pragma mark - Event handling
- (void)donePhotoSelection:(id)sender
{
    [self.photoLibrary.selectedAssets setValue:@(NO) forKey:@"selected"];
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingImageAssets:)]) {
            [self.delegate imagePickerController:self didFinishPickingImageAssets:self.photoLibrary.selectedAssets];
        }
    }];
}

- (void)closeAlbum:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(imagePickerControllerDidClose:)]) {
            [self.delegate imagePickerControllerDidClose:self];
        }
    }];
}

@end
