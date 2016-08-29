//
//  KLImagePickerController.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLImagePickerController.h"
#import "KLAlbumViewController.h"
#import "KLSegmentControl.h"

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

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Life cycle
+ (instancetype)imagePickerController
{
    return [[self alloc] initWithPhotoLibrary:[KLPhotoLibrary new]];
}

- (instancetype)initWithPhotoLibrary:(KLPhotoLibrary *)photoLibrary
{
    if (self = [super init]) {
        _photoLibrary = photoLibrary;
        _scaleTransition = [KLScaleTransition transitionWithGestureEnabled:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
    [self addObservers];
    
    [self.photoLibrary checkAuthorization:^{
        [self showAlert];
    }];
}

- (void)prepareForUI
{
    self.view.backgroundColor = [UIColor blackColor];
    [self addPageViewController];
    [self addSubviews];
    [self addViewConstraints];
}

#pragma mark - Observer
- (void)addObservers
{
    self.KVOController = [FBKVOController controllerWithObserver:self];
    [self.KVOController observe:self.photoLibrary keyPath:NSStringFromSelector(@selector(assetCollections)) options:0 action:@selector(reloadData)];
    [self.KVOController observe:self.photoLibrary keyPath:NSStringFromSelector(@selector(selectedAssets)) options:0 action:@selector(selectedAssetsChanged)];
}

- (void)reloadData
{
    self.pageScrollView.scrollEnabled = self.photoLibrary.isPageScrollEnabled;
    
    UIViewController *viewController = [self viewControllerAtPageIndex:self.photoLibrary.currentPageIndex];
    if (viewController) {
        [self.pageViewController setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    } else if (self.pageViewController.childViewControllers.count) {
        [self.pageViewController.childViewControllers makeObjectsPerformSelector:@selector(willMoveToParentViewController:) withObject:nil];
        [self.pageViewController.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.pageViewController.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    }
    
    self.segmentControl.items = self.photoLibrary.assetCollectionTitles;
    [self.segmentControl reloadData];
}

- (void)selectedAssetsChanged
{
    NSUInteger count = self.photoLibrary.selectedAssets.count;
    self.bottomBarItem.title = count ? [NSString stringWithFormat:TITLE_SELECTED_PHOTO_COUNT, count] : nil;
    self.bottomBarItem.rightBarButtonItem.enabled = count > 0;
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
    _segmentControl = [KLSegmentControl segmentControlWithItems:nil];
    _segmentControl.delegate = self;
    [self.view addSubview:_segmentControl];
    
    _bottomBarItem = [[UINavigationItem alloc] init];
    _bottomBarItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImageName:@"button_close" target:self action:@selector(closeAlbum:)];
    _bottomBarItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithTitle:BUTTON_TITLE_DONE target:self action:@selector(donePhotoSelection:)];
    _bottomBarItem.rightBarButtonItem.enabled = NO;
    [self.bottomBarItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldTitleFont]} forState:UIControlStateNormal];
    
    _bottomBar = [[UINavigationBar alloc] init];
    _bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    _bottomBar.items = @[_bottomBarItem];
    _bottomBar.tintColor = [UIColor whiteColor];
    _bottomBar.barTintColor = [UIColor darkBackgroundColor];
    _bottomBar.titleTextAttributes = @{ NSForegroundColorAttributeName : _bottomBar.tintColor };
    [self.view addSubview:_bottomBar];
}

- (void)addViewConstraints
{
    UIView *pageView = self.pageViewController.view;
    id<UILayoutSupport> topLayoutGuide = self.topLayoutGuide;
    NSDictionary *views = NSDictionaryOfVariableBindings(topLayoutGuide, _segmentControl, _bottomBar, pageView);
    NSDictionary *metrics = @{ @"margin": @(2.0) };
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_segmentControl]|" views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide][_segmentControl]-margin-[pageView]-margin-[_bottomBar]|" options:NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing metrics:metrics views:views]];
    
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
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? 44 : 34;
}

- (void)showAlert
{
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:BUTTON_TITLE_CANCEL style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:BUTTON_TITLE_SETTING style:UIAlertActionStyleCancel handler:^(id action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    NSString *message = [NSString localizedStringWithFormat:MSG_ACCESS_PHOTOS_SETTING, [APP_DISPLAY_NAME quotedString], [PATH_PHOTOS_SETTING quotedString]];
    [[UIAlertController alertControllerWithTitle:TITLE_PHOTOS message:message actions:@[setting, cancel]] show];
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
    if (self.photoLibrary.assetCollectionCount == 0 || index >= self.photoLibrary.assetCollectionCount) return nil;
    
    KLAlbumViewController *albumVC = [KLAlbumViewController viewControllerWithPageIndex:index photoLibrary:self.photoLibrary];
    
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
    KLAlbumViewController *albumVC = self.pageViewController.viewControllers.firstObject;
    self.photoLibrary.currentPageIndex = albumVC.pageIndex;
    [self.segmentControl selectSegmentAtIndex:albumVC.pageIndex];
}

#pragma mark - Segment control delegate
- (void)segmentControl:(KLSegmentControl *)segmentControl didSelectSegmentAtIndex:(NSUInteger)index
{
    if (self.photoLibrary.currentPageIndex == index) return;
    
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
