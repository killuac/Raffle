//
//  KLMainViewController.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLMainViewController.h"
#import "KLDrawPoolViewController.h"
#import "KLImagePickerController.h"
#import "KLMoreViewController.h"

@interface KLMainViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) KLMainViewModel *viewModel;

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation KLMainViewController

#pragma mark - Life cycle
- (instancetype)init
{
    if (self = [super init]) {
        _viewModel = [KLMainViewModel new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
    [self reloadData];
}

- (void)prepareForUI
{
    [self addPageViewController];
    [self addSubviews];
}

- (void)reloadData
{
    self.pageScrollView.scrollEnabled = self.viewModel.isPageScrollEnabled;
    
    UIViewController *viewController = [self viewControllerAtPageIndex:self.viewModel.currentPageIndex];
    if (viewController) {
        [self.pageViewController setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    } else if (self.pageViewController.childViewControllers.count) {
        [self.pageViewController.childViewControllers makeObjectsPerformSelector:@selector(willMoveToParentViewController:) withObject:nil];
        [self.pageViewController.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.pageViewController.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
        [self addDefaultView];
    }
}

// Add default view when there is no any draw pool
- (void)addDefaultView
{
    
}

- (void)addPageViewController
{
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    _pageViewController.view.backgroundColor = [UIColor backgroundColor];
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
//  Page control
    [self.view addSubview:({
        _pageControl = [UIPageControl newAutoLayoutView];
        _pageControl.enabled = NO;
        _pageControl.numberOfPages = self.viewModel.drawPoolCount;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl;
    })];
    
//  Toolbar
    [self.view addSubview:({
        UIBarButtonItem *reloadItem = [UIBarButtonItem barButtonItemWithImageName:@"button_reload" target:self action:@selector(reloadPhotos:)];
        UIBarButtonItem *addItem = [UIBarButtonItem barButtonItemWithImageName:@"button_add" target:self action:@selector(addPhotos:)];
        UIBarButtonItem *menuItem = [UIBarButtonItem barButtonItemWithImageName:@"button_menu" target:self action:@selector(slideMenu:)];
        
        _toolbar = [UIToolbar toolbarWithItems:@[reloadItem, addItem, menuItem]];
        [self.toolbar setSeparatorColor:[UIColor separatorColor]];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTakePhoto:)];
        [self.toolbar addGestureRecognizer:longPress];
        
        _toolbar;
    })];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_pageControl, _toolbar);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|" views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageControl(10)]-10-[_toolbar]|" options:NSLayoutFormatAlignAllCenterX views:views]];
}

#pragma mark - Page view controller datasource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(KLDrawPoolViewController *)viewController
{
    NSUInteger index = viewController.pageIndex;
    if (index == 0 || index == NSNotFound) return nil;
    
    return [self viewControllerAtPageIndex:index-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(KLDrawPoolViewController *)viewController
{
    NSUInteger index = viewController.pageIndex;
    if (index == NSNotFound) return nil;
    
    return [self viewControllerAtPageIndex:index+1];
}

- (KLDrawPoolViewController *)viewControllerAtPageIndex:(NSUInteger)index
{
    if (self.viewModel.drawPoolCount == 0 || index >= self.viewModel.drawPoolCount) return nil;
    
    KLDrawPoolViewModel *poolViewModel = [self.viewModel drawPoolViewModelAtIndex:index];
    KLDrawPoolViewController *VC = [KLDrawPoolViewController viewControllerWithPageIndex:index viewModel:poolViewModel];
    
    return VC;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        self.viewModel.currentPageIndex = [pageViewController.viewControllers.firstObject pageIndex];
        self.pageControl.currentPage = self.viewModel.currentPageIndex;
    }
}

#pragma mark - Event handling
- (void)addPhotos:(id)sender
{
    
}

- (void)reloadPhotos:(id)sender
{
    
}

- (void)slideMenu:(id)sender
{
    KLMoreViewController *moreVC = [KLMoreViewController viewController];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:moreVC];
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)takePhoto:(id)sender
{
    
}

- (void)choosePhoto:(id)sender
{
    
}

- (void)longPressTakePhoto:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;
    
    UIView *view = recognizer.view;
    CGRect frame = CGRectMake(view.width/3, 0, view.width/3, view.height);
    if (!CGRectContainsPoint(frame, [recognizer locationInView:view])) return;
    
    KLImagePickerController *imagePicker = [KLImagePickerController imagePickerController];
    imagePicker.delegate = self.pageViewController.viewControllers.firstObject; // FIXME: maybe nil
    imagePicker.transitioningDelegate = imagePicker.scaleTransition;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)showDrawModes:(id)sender
{
    
}

@end
