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
#import "KLCameraViewController.h"
#import "KLMoreViewController.h"
#import "KLResultViewController.h"
#import "KLPhotoViewController.h"

#define MINIMUM_SCALE CGAffineTransformMakeScale(0.001, 0.001)

@interface KLMainViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, KLImagePickerControllerDelegate>

@property (nonatomic, strong) KLMainDataController *dataController;
@property (nonatomic, readonly) KLDrawBoxViewController *drawBoxViewController;

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) KLBubbleButton *addPhotoButton;
@property (nonatomic, strong) KLBubbleButton *switchModeButton;
@property (nonatomic, strong) KLBubbleButton *reloadButton;
@property (nonatomic, strong) KLBubbleButton *menuButton;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
    [self reloadData];
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
    [self addPageViewController];
    [self addSubviews];
    [self addTapGesture];
}

- (void)reloadData
{
    self.pageControl.hidden = (self.dataController.pageCount == 1);
    self.pageControl.numberOfPages = self.dataController.pageCount;
    self.pageScrollView.scrollEnabled = self.dataController.pageCount > 0;
    
    UIViewController *viewController = [self viewControllerAtPageIndex:self.dataController.currentPageIndex];
    if (viewController) {
        [self.pageViewController setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    } else if (self.pageViewController.childViewControllers.count) {
        [self.pageViewController.childViewControllers makeObjectsPerformSelector:@selector(willMoveToParentViewController:) withObject:nil];
        [self.pageViewController.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.pageViewController.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    }
    
    [self becomeFirstResponder];
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
        _addPhotoButton = [KLBubbleButton buttonWithTitle:@"2" imageName:@"icon_main_add"];
        _addPhotoButton.titleLabel.font = [UIFont titleFont];
        _addPhotoButton.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        _addPhotoButton.layout = KLButtonLayoutVerticalImageUp;
        [self.addPhotoButton addTarget:self action:@selector(addPhotosToDrawBox:)];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTakePhoto:)];
        [self.addPhotoButton addGestureRecognizer:longPress];
        _addPhotoButton;
    })];
    
//  Bottom buttons
    [self.view addSubview:({
        _switchModeButton = [KLBubbleButton buttonWithImageName:@"icon_attendee_mode"];
        _switchModeButton.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
        [_switchModeButton addTarget:self action:@selector(switchDrawMode:)];
        _switchModeButton;
    })];
    
    [self.view addSubview:({
        _reloadButton = [KLBubbleButton buttonWithImageName:@"icon_reload"];
        _reloadButton.hidden = YES;
        _reloadButton.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
        [_reloadButton addTarget:self action:@selector(reloadDrawBox:)];
        _reloadButton;
    })];
    
    [self.view addSubview:({
        _menuButton = [KLBubbleButton buttonWithImageName:@"icon_menu"];
        _menuButton.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
        [_menuButton addTarget:self action:@selector(showMoreDrawBoxes:)];
        _menuButton;
    })];
    
//  Add constraints
    [NSLayoutConstraint constraintWidthWithItem:self.addPhotoButton constant:KLViewDefaultButtonHeight*2].active = YES;
    [self.addPhotoButton constraintsEqualWidthAndHeight];
    [self.addPhotoButton constraintsCenterInSuperview];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_pageControl, _switchModeButton, _reloadButton, _menuButton);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_switchModeButton(40)]->=0-[_reloadButton(40)]->=0-[_menuButton(40)]-8-|" options:NSLayoutFormatAlignAllCenterY views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageControl][_reloadButton]-8-|" views:views]];
    
    [self.pageControl constraintsCenterXWithView:self.view];
    [self.reloadButton constraintsCenterXWithView:self.view];
    [self.reloadButton constraintsEqualWidthAndHeight];
    [self.switchModeButton constraintsEqualWidthAndHeight];
    [self.menuButton constraintsEqualWidthAndHeight];
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

#pragma mark - KLImagePickerController delegate
- (void)imagePickerController:(KLImagePickerController *)picker didFinishPickingImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.dataController addDrawBoxWithAssets:assets];
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

#pragma mark - Event handling
- (void)startDraw:(id)sender
{
    self.isDrawing = YES;
    [self resignFirstResponder];
    [self setAddPhotoButtonHidden:YES];
    [self setBottomButtonsHidden:YES];
    [KLSoundPlayer playStartDrawSound];
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
    [self.drawBoxViewController randomAnPhoto:^(UIImage *image, NSDictionary *info) {
        KLResultViewController *resultVC = [KLResultViewController viewController];
        resultVC.resultImage = image;
        [self presentViewController:resultVC animated:YES completion:^{
            [self setAddPhotoButtonHidden:NO];
            [self setBottomButtonsHidden:NO];
        }];
    }];
    [KLSoundPlayer playStopDrawSound];
}

- (void)addPhotosToDrawBox:(id)sender
{
    [KLImagePickerController checkAuthorization:^{
        KLImagePickerController *imagePicker = [KLImagePickerController imagePickerController];
        imagePicker.delegate = self.dataController.pageCount > 0 ? self.drawBoxViewController : self;
        imagePicker.transition = [KLCircleTransition transition];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
}

- (void)switchDrawMode:(id)sender
{
    if (self.dataController.itemCount == 0) return;
    
    [self.dataController switchDrawMode];
    [self setReloadButtonHidden:self.dataController.isReloadButtonHidden];
    
    [UIView animateWithDefaultDuration:^{
        UIViewAnimationTransition transition = self.dataController.isAttendeeMode ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft;
        [UIView setAnimationTransition:transition forView:self.switchModeButton cache:YES];
        
        KLDispatchMainAfter(KLViewDefaultAnimationDuration/2, ^{
            NSString *imageName = self.dataController.isAttendeeMode ? @"icon_attendee_mode" : @"icon_prize_mode";
            [self.switchModeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        });
    } completion:^(BOOL finished) {
//      TODO: Swich animation
    }];
}

- (void)reloadDrawBox:(id)sender
{
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

- (void)longPressTakePhoto:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;
    
    // TODO: Show camera view contoller
}

@end
