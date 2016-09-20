//
//  KLMainViewController.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLMainViewController.h"
#import "KLDrawBoxViewController.h"
#import "KLImagePickerController.h"
#import "KLMoreViewController.h"

@interface KLMainViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) KLMainDataController *dataController;

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIButton *addPhotoButton;
@property (nonatomic, strong) UIButton *switchModeButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIButton *menuButton;

@end

@implementation KLMainViewController

#pragma mark - Life cycle
- (instancetype)init
{
    if (self = [super init]) {
        _dataController = [KLMainDataController dataController];
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
    self.pageControl.hidden = (self.dataController.pageCount == 1);
    self.pageControl.numberOfPages = self.dataController.pageCount;
    self.pageScrollView.scrollEnabled = self.dataController.isPageScrollEnabled;
    
    UIViewController *viewController = [self viewControllerAtPageIndex:self.dataController.currentPageIndex];
    if (viewController) {
        [self.pageViewController setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    } else if (self.pageViewController.childViewControllers.count) {
        [self.pageViewController.childViewControllers makeObjectsPerformSelector:@selector(willMoveToParentViewController:) withObject:nil];
        [self.pageViewController.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.pageViewController.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    }
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
        _pageControl.numberOfPages = self.dataController.pageCount;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl;
    })];
    
//  Add photo button
    [self.view addSubview:({
        _addPhotoButton = [UIButton buttonWithTitle:@"2" imageName:@"button_add"];
        _addPhotoButton.titleLabel.font = [UIFont titleFont];
        _addPhotoButton.style = KLButonStylePrimary;
        _addPhotoButton.layout = KLButtonLayoutVerticalImageUp;
        _addPhotoButton.layer.cornerRadius = KLViewDefaultHeight;
        [self.addPhotoButton addTarget:self action:@selector(addPhotosToDrawBox:)];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTakePhoto:)];
        [self.addPhotoButton addGestureRecognizer:longPress];
        _addPhotoButton;
    })];
    
//  Bottom buttons
    [self.view addSubview:({
        _switchModeButton = [UIButton buttonWithImageName:@"button_menu"];
        [_switchModeButton addTarget:self action:@selector(switchDrawMode:)];
        _switchModeButton;
    })];
    
    [self.view addSubview:({
        _reloadButton = [UIButton buttonWithImageName:@"button_reload"];
        [_reloadButton addTarget:self action:@selector(reloadDrawBox:)];
        _reloadButton;
    })];
    
    [self.view addSubview:({
        _menuButton = [UIButton buttonWithImageName:@"button_menu"];
        [_menuButton addTarget:self action:@selector(showMoreDrawBoxes:)];
        _menuButton;
    })];
    
//  Add constraints
    [NSLayoutConstraint constraintWidthWithItem:self.addPhotoButton constant:KLViewDefaultHeight*2].active = YES;
    [self.addPhotoButton constraintsEqualWidthAndHeight];
    [self.addPhotoButton constraintsCenterInSuperview];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_pageControl, _switchModeButton, _reloadButton, _menuButton);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_switchModeButton]->=0-[_reloadButton]->=0-[_menuButton]-15-|" options:NSLayoutFormatAlignAllCenterY views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageControl][_reloadButton]-15-|" views:views]];
    [self.pageControl constraintsCenterXWithView:self.view];
    [self.reloadButton constraintsCenterXWithView:self.view];
}

#pragma mark - Page view controller datasource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(KLDrawBoxViewController *)viewController
{
    NSUInteger index = viewController.pageIndex;
    if (index == 0 || index == NSNotFound) return nil;
    
    return [self viewControllerAtPageIndex:index-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(KLDrawBoxViewController *)viewController
{
    NSUInteger index = viewController.pageIndex;
    if (index == NSNotFound) return nil;
    
    return [self viewControllerAtPageIndex:index+1];
}

- (KLDrawBoxViewController *)viewControllerAtPageIndex:(NSUInteger)index
{
    if (self.dataController.pageCount == 0 || index >= self.dataController.pageCount) return nil;
    
    KLDrawBoxViewController *VC = [KLDrawBoxViewController viewControllerWithDataController:self.dataController atPageIndex:index];
    
    return VC;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        self.dataController.currentPageIndex = [pageViewController.viewControllers.firstObject pageIndex];
        self.pageControl.currentPage = self.dataController.currentPageIndex;
    }
}

#pragma mark - Animation
- (void)setAddPhotoButtonHidden:(BOOL)hidden
{
    
}

- (void)setBottomButtonsHidden:(BOOL)hidden
{
    
}

- (void)setReloadButtonHidden:(BOOL)hidden
{
    
}

#pragma mark - Event handling
- (void)startDraw:(id)sender
{
    [self setAddPhotoButtonHidden:YES];
    [self setBottomButtonsHidden:YES];
}

- (void)stopDraw:(id)sender
{
    [self setAddPhotoButtonHidden:NO];
    [self setBottomButtonsHidden:NO];
}

- (void)addPhotosToDrawBox:(id)sender
{
    [self showImagePickerController];
}

- (void)switchDrawMode:(id)sender
{
    [self setReloadButtonHidden:YES];
    
    [UIView animateWithDefaultDuration:^{
        self.switchModeButton.transform = CGAffineTransformMakeScale(0.001, 0.001);
    } completion:^(BOOL finished) {
        [UIView animateWithDefaultDuration:^{
            self.switchModeButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)reloadDrawBox:(id)sender
{
    
}

- (void)showMoreDrawBoxes:(id)sender
{
    KLMoreViewController *moreVC = [KLMoreViewController viewController];
    moreVC.dismissBlock = ^{ [self reloadData]; };
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:moreVC];
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)longPressTakePhoto:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;
    
    UIView *view = recognizer.view;
    CGRect frame = CGRectMake(view.width/3, 0, view.width/3, view.height);
    if (CGRectContainsPoint(frame, [recognizer locationInView:view])) {
        [self showImagePickerController];
    }
}

- (void)showImagePickerController
{
    KLImagePickerController *imagePicker = [KLImagePickerController imagePickerController];
    imagePicker.delegate = self.pageViewController.viewControllers.firstObject;
    imagePicker.transitioningDelegate = imagePicker.transition;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

@end
