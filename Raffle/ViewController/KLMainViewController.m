//
//  KLMainViewController.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLMainViewController.h"
#import "KLBubbleButton.h"
#import "KLCircleTransition.h"
#import "KLDrawBoxViewController.h"
#import "KLImagePickerController.h"
#import "KLMoreViewController.h"
#import "KLResultViewController.h"
#import "KLPhotoViewController.h"
#import "KLWallpaperViewController.h"

#define MINIMUM_SCALE CGAffineTransformMakeScale(0.001, 0.001)

@interface KLMainViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, KLDataControllerDelegate, KLImagePickerControllerDelegate, KLCameraViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, readonly) UIScrollView *pageScrollView;
@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) KLBubbleButton *addPhotoButton;
@property (nonatomic, strong) UIButton *switchModeButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIButton *wallpaperButton;

@property (nonatomic, assign) BOOL isDrawing;

@end

@implementation KLMainViewController

#pragma mark - Lifecycle
- (instancetype)init
{
    if (self = [super init]) {
        _dataController = [KLMainDataController dataController];
        _dataController.delegate = self;
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
    [self reloadData];
    [self addObservers];
}

- (BOOL)canBecomeFirstResponder
{
    return (self.dataController.pageCount && self.dataController.currentDrawBoxDC.isShakeEnabled);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}

- (KLDrawBoxViewController *)drawBoxViewController
{
    return self.pageViewController.viewControllers.firstObject;
}

#pragma mark - Prepare UI
- (void)prepareForUI
{
    self.view.backgroundColor = [UIColor darkBackgroundColor];
    
    [self addPageViewController];
    [self addSubviews];
    [self addTapGesture];
}

- (void)reloadData
{
    self.bgImageView.hidden = (self.dataController.pageCount > 0);
    
    self.pageControl.hidden = (self.dataController.pageCount <= 1);
    self.pageControl.numberOfPages = self.dataController.pageCount;
    self.pageControl.currentPage = self.dataController.currentPageIndex;
    self.pageScrollView.scrollEnabled = self.dataController.pageCount > 0;
    
    UIViewController *viewController = [self viewControllerAtPageIndex:self.dataController.currentPageIndex];
    if (viewController) {
        [self.pageViewController setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    } else if (self.pageViewController.childViewControllers.count) {
        [self.pageViewController.childViewControllers makeObjectsPerformSelector:@selector(willMoveToParentViewController:) withObject:nil];
        [self.pageViewController.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.pageViewController.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    }
    
    [self becomeFirstResponder];    // For motion detection
    [self updateAddPhotoButtonTitle];
}

- (void)addPageViewController
{
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    self.pageScrollView.delegate = self;
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
//  Wallpaper
    [self.view addSubview:({
        _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bgImageView.hidden = YES;
        _bgImageView.alpha = 0.8;
        _bgImageView.image = [UIImage imageNamed:@"wallpaper0.jpg"];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _bgImageView;
    })];
    
//  Page control
    [self.view addSubview:({
        _pageControl = [UIPageControl newAutoLayoutView];
        _pageControl.enabled = NO;
        _pageControl.numberOfPages = self.dataController.pageCount;
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl;
    })];
    
//  Add photo button
    [self.view addSubview:({
        _addPhotoButton = [KLBubbleButton buttonWithTitle:nil imageName:@"icon_main_add"];
        _addPhotoButton.titleLabel.font = [UIFont titleFont];
//        _addPhotoButton.backgroundColor = [KLColorWithRGB(199, 92, 92) colorWithAlphaComponent:0.2];
//        _addPhotoButton.backgroundColor = [KLColorWithRGB(118, 194, 175) colorWithAlphaComponent:0.2];
//        _addPhotoButton.backgroundColor = [KLColorWithRGB(119, 129, 212) colorWithAlphaComponent:0.2];
//        _addPhotoButton.backgroundColor = [KLColorWithRGB(245, 207, 135) colorWithAlphaComponent:0.2];
//        _addPhotoButton.backgroundColor = [KLColorWithRGB(224, 153, 94) colorWithAlphaComponent:0.2];
//        _addPhotoButton.backgroundColor = [KLColorWithRGB(79, 93, 115) colorWithAlphaComponent:0.2];
        [self.addPhotoButton addTarget:self action:@selector(addPhotosToDrawBox:)];
        [self.addPhotoButton addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToShowCameraViewController:)]];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        animation.duration = 2.0;
        animation.repeatCount = HUGE_VALF;
        animation.autoreverses = YES;
        animation.fromValue = (__bridge id)[KLColorWithRGB(199, 92, 92) colorWithAlphaComponent:0.3].CGColor;
        animation.toValue = (__bridge id)[KLColorWithRGB(119, 129, 212) colorWithAlphaComponent:0.3].CGColor;
        [self.addPhotoButton.layer addAnimation:animation forKey:@"ColorPulse"];
        
        _addPhotoButton;
    })];
    [self.addPhotoButton constraintsCenterInSuperview];
    [self.addPhotoButton constraintsEqualWidthAndHeight];
    [NSLayoutConstraint constraintHeightWithItem:self.addPhotoButton constant:70].active = YES;
    
//  Bottom buttons
    [self.view addSubview:({
        _wallpaperButton = [UIButton buttonWithImageName:@"icon_wallpaper"];
        [_wallpaperButton addTarget:self action:@selector(showWallpaperViewController:)];
        _wallpaperButton;
    })];
    
    [self.view addSubview:({
        _switchModeButton = [UIButton buttonWithImageName:@"icon_repeat_off"];
        [_switchModeButton addTarget:self action:@selector(switchDrawMode:)];
        _switchModeButton;
    })];
    
    [self.view addSubview:({
        _reloadButton = [UIButton buttonWithImageName:@"icon_reload"];
        _reloadButton.hidden = YES;
        [_reloadButton addTarget:self action:@selector(reloadDrawBox:)];
        _reloadButton;
    })];
    
    [self.view addSubview:({
        _menuButton = [UIButton buttonWithImageName:@"icon_menu"];
        [_menuButton addTarget:self action:@selector(showMoreDrawBoxes:)];
        _menuButton;
    })];
    
//  Add constraints
    NSDictionary *views = NSDictionaryOfVariableBindings(_pageControl, _addPhotoButton, _wallpaperButton, _switchModeButton, _reloadButton, _menuButton);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_wallpaperButton(40)]->=0-[_switchModeButton(40)]->=0-[_menuButton(40)]|" options:NSLayoutFormatAlignAllBottom views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_switchModeButton]|" views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageControl]-30-|" views:views]];
    
    [self.pageControl constraintsCenterXWithView:self.view];
    [self.switchModeButton constraintsCenterXWithView:self.view];
    [self.switchModeButton constraintsEqualWidthAndHeight];
    [self.reloadButton constraintsEqualWidthAndHeight];
    [self.menuButton constraintsEqualWidthAndHeight];
    [self.wallpaperButton constraintsEqualWidthAndHeight];
}

- (void)updateAddPhotoButtonTitle
{
    NSUInteger assetCount = self.dataController.currentDrawBoxDC.remainingAssetCount;
    NSString *title = assetCount > 0 ? @(assetCount).stringValue : nil;
    if (title && ![title isEqualToString:self.addPhotoButton.currentTitle]) {
        [self.addPhotoButton setNormalTitle:title];
        self.addPhotoButton.layout = assetCount > 0 ? KLButtonLayoutImageUp : KLButtonLayoutNone;
    }
}

#pragma mark - Observers
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTouchStart:) name:KLPhotoViewControllerDidTouchStart object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [self removeObservers];
}

- (void)didTouchStart:(NSNotification *)notification
{
    KLDrawBoxDataController *drawboxDC = notification.object;
    self.dataController.currentPageIndex = drawboxDC.pageIndex;
    [self reloadData];
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
        self.dataController.currentPageIndex = self.drawBoxViewController.pageIndex;
        self.pageControl.currentPage = self.dataController.currentPageIndex;
        [self updateAddPhotoButtonTitle];
    }
}

#pragma mark - Scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (0 == self.pageControl.currentPage && scrollView.contentOffset.x < scrollView.width) {
        scrollView.contentOffset = CGPointMake(scrollView.width, 0);
    }
    if (self.pageControl.currentPage == self.pageControl.numberOfPages-1 && scrollView.contentOffset.x > scrollView.width) {
        scrollView.contentOffset = CGPointMake(scrollView.width, 0);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (0 == self.pageControl.currentPage && scrollView.contentOffset.x <= scrollView.width) {
        *targetContentOffset = CGPointMake(scrollView.width, 0);
    }
    if (self.pageControl.currentPage == self.pageControl.numberOfPages-1 && scrollView.contentOffset.x >= scrollView.width) {
        *targetContentOffset = CGPointMake(scrollView.width, 0);
    }
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

#pragma mark - Motion
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (self.isFirstResponder && motion == UIEventSubtypeMotionShake) {
        [self startDraw:event];
    }
}

#pragma mark - Animation
- (void)setAddPhotoButtonHidden:(BOOL)hidden
{
    [UIView animateWithDefaultDuration:^{
        self.addPhotoButton.transform = hidden ? MINIMUM_SCALE : CGAffineTransformIdentity;
    }];
}

- (void)setBottomButtonsHidden:(BOOL)hidden
{
    [self setReloadButtonHidden:hidden];
    
    if (!hidden) self.switchModeButton.hidden = hidden;
    [UIView animateWithDefaultDuration:^{
        self.switchModeButton.transform = hidden ? CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, self.reloadButton.height), M_PI) : CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.switchModeButton.hidden = hidden;
    }];
    
    if (!hidden) self.menuButton.hidden = hidden;
    [UIView animateWithDefaultDuration:^{
        self.menuButton.transform = hidden ? CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, self.reloadButton.height), M_PI) : CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.menuButton.hidden = hidden;
    }];
}

- (void)setReloadButtonHidden:(BOOL)hidden
{
    if (!hidden) self.reloadButton.hidden = hidden;
    [UIView animateWithDefaultDuration:^{
        self.reloadButton.transform = hidden ? CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, self.reloadButton.height), M_PI) : CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.reloadButton.hidden = hidden;
    }];
}

- (void)setPageControlHidden:(BOOL)hidden
{
    self.pageScrollView.scrollEnabled = !hidden;
    [self.pageControl setHidden:hidden animated:YES];
}

#pragma mark - Event handling
- (void)startDraw:(id)sender
{
    [KLSoundPlayer playStartDrawSound];
    
    self.isDrawing = YES;
    [self resignFirstResponder];
    [self setAddPhotoButtonHidden:YES];
    [self setBottomButtonsHidden:YES];
    [self setPageControlHidden:YES];
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer
{
    if (self.isDrawing) {   // 摇奖中...
        self.isDrawing = NO;
        [self becomeFirstResponder];
        [self stopDraw:recognizer];
    }
}

- (void)stopDraw:(id)sender
{
    [KLSoundPlayer playStopDrawSound];
    
    KLResultViewController *resultVC = [KLResultViewController viewController];
    resultVC.pickedAsset = [self.dataController.currentDrawBoxDC randomAnAsset];
    resultVC.dismissBlock = ^(id object) {
        [self reloadData];
    };
    [self presentViewController:resultVC animated:YES completion:^{
        [self setAddPhotoButtonHidden:NO];
        [self setBottomButtonsHidden:NO];
        [self setPageControlHidden:NO];
    }];
}

- (void)addPhotosToDrawBox:(id)sender
{
    [KLImagePickerController checkAuthorization:^{
        KLImagePickerController *imagePicker = [KLImagePickerController imagePickerController];
        imagePicker.transition = [KLCircleTransition transition];
        imagePicker.delegate = self.dataController.pageCount > 0 ? self.drawBoxViewController : self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
}

- (void)switchDrawMode:(id)sender
{
    if (self.dataController.itemCount == 0) return;
    
    [self.dataController switchDrawMode];
    [self setReloadButtonHidden:self.dataController.isReloadButtonHidden];
    
    [UIView animateWithDefaultDuration:^{
        self.switchModeButton.alpha = 0;
    } completion:^(BOOL finished) {
        NSString *imageName = self.dataController.isRepeatMode ? @"icon_repeat_on" : @"icon_repeat_off";
        [self.switchModeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [self.switchModeButton setHidden:NO animated:YES];
    }];
}

- (void)reloadDrawBox:(id)sender
{
    [self setReloadButtonHidden:YES];
    [self.dataController.currentDrawBoxDC reloadAllAssets];
    [self.drawBoxViewController reloadData];
}

- (void)showMoreDrawBoxes:(id)sender
{
    KLMoreViewController *moreVC = [KLMoreViewController viewControllerWithDataController:self.dataController];    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:moreVC];
    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)longPressToShowCameraViewController:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;
    
    KLCameraViewController *cameraVC = [KLCameraViewController cameraViewControllerWithAlbumImage:nil];
    cameraVC.transition = [KLCircleTransition transition];
    cameraVC.delegate = self.dataController.pageCount > 0 ? self.drawBoxViewController : self;
    [self presentViewController:cameraVC animated:YES completion:nil];
}

#pragma mark - Switch draw mode animation
- (void)startSwitchDrawModeAnimation
{
    // TODO: Switch background image
}

- (NSArray *)createSliceViews
{
    CGFloat sliceWidth = 5.0;
    UIView *view = [self.view snapshotViewAfterScreenUpdates:NO];
    NSMutableArray *sliceViews = [NSMutableArray array];
    
    for (NSUInteger x = 0; x < self.view.width; x += sliceWidth) {
        CGRect rect = CGRectMake(x, 0, sliceWidth, view.height);
        UIView *sliceView = [view resizableSnapshotViewFromRect:rect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        sliceView.frame = rect;
        [sliceViews addObject:sliceView];
    }
    
    return sliceViews;
}

- (void)randomPositionOfViewSlices:(NSArray *)sliceViews fromUp:(BOOL)fromUp
{
    CGFloat height;
    BOOL isFromUp = fromUp;
    for (UIView *sliceView in sliceViews) {
        height = sliceView.height * KLRandomFloat(1.0, 4.0);
        sliceView.top += fromUp ? -height : height;
        isFromUp = !isFromUp;
    }
}

- (void)resetYForSliceViews:(NSArray *)sliceViews
{
    [sliceViews setValue:@(self.view.top) forKey:@"top"];
}

#pragma mark - Image picker and camera delegate
- (void)imagePickerController:(KLImagePickerController *)picker didFinishPickingImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.dataController addDrawBoxWithAssets:assets];
}

- (void)cameraViewController:(KLCameraViewController *)cameraVC didFinishSaveImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.dataController addDrawBoxWithAssets:assets];
}

#pragma mark - Wallpaper
- (void)showWallpaperViewController:(id)sender
{
    [self.drawBoxViewController showWallpaperViewController];
}

@end
