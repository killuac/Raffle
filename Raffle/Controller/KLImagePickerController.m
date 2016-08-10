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
@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UINavigationItem *navigationItem;

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
    [self addPageViewController];
    [self addSubviews];
}

- (void)addObservers
{
    self.KVOController = [FBKVOController controllerWithObserver:self];
    [self.KVOController observe:self.photoLibrary keyPath:NSStringFromSelector(@selector(assetCollections)) options:0 action:@selector(reloadData)];
}

- (void)reloadData
{
    self.pageScrollView.scrollEnabled = self.photoLibrary.isPageScrollEnabled;
    
    UIViewController *viewController = [self viewControllerAtPageIndex:self.photoLibrary.selectedAssetCollectionIndex];
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

- (void)addPageViewController
{
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    self.pageScrollView.delegate = self;
    self.pageViewController.view.backgroundColor = [UIColor blackColor];
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
    
    _navigationItem = [[UINavigationItem alloc] init];
    _navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImageName:@"button_close" target:self action:@selector(closeAlbum:)];
    _navigationBar = [[UINavigationBar alloc] init];
    _navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    _navigationBar.items = @[_navigationItem];
    _navigationBar.tintColor = [UIColor whiteColor];
    _navigationBar.barTintColor = [UIColor darkBackgroundColor];
    _navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : _navigationBar.tintColor };
    [self.view addSubview:_navigationBar];
}

- (void)updateViewConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_segmentControl, _navigationBar);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_segmentControl]|" views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_segmentControl]" views:views]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_navigationBar]|" views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_navigationBar]|" views:views]];
    
    [super updateViewConstraints];
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
    CGFloat offsetRate = (scrollView.contentOffset.x - scrollView.width) / scrollView.width;
    [self.segmentControl scrollWithOffsetRate:offsetRate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    KLAlbumViewController *albumVC = self.pageViewController.viewControllers.firstObject;
    [self.segmentControl selectSegmentAtIndex:albumVC.pageIndex];
    self.photoLibrary.selectedAssetCollectionIndex = albumVC.pageIndex;
}

#pragma mark - Segment control delegate
- (void)segmentControl:(KLSegmentControl *)segmentControl didSelectSegmentAtIndex:(NSUInteger)index
{
    DECLARE_WEAK_SELF;
    KLAlbumViewController *albumVC = self.pageViewController.viewControllers.firstObject;
    UIPageViewControllerNavigationDirection direction = (albumVC.pageIndex < index) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    
    self.pageScrollView.delegate = nil;
    self.photoLibrary.selectedAssetCollectionIndex = index;
    [self.pageViewController setViewControllers:@[[self viewControllerAtPageIndex:index]] direction:direction animated:YES completion:^(BOOL finished) {
        welf.pageScrollView.delegate = welf;
    }];
}

#pragma mark - Event handling
- (void)addPhotoCompletion:(id)sender
{
    
}

- (void)closeAlbum:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(imagePickerControllerDidClose:)]) {
            [self.delegate imagePickerControllerDidClose:self];
        }
    }];
}

- (void)unselectPhotos:(id)sender
{
    
}

- (void)selectAllPhotos:(id)sender
{
    
}

@end
