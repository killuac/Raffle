//
//  KLResultViewController.m
//  Raffle
//
//  Created by Killua Liu on 9/19/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLResultViewController.h"
#import "KLSwapTransition.h"
#import "PHAsset+Model.h"
@import GoogleMobileAds;

@interface KLResultViewController () <GADBannerViewDelegate>

@property (nonatomic, strong) UIImageView *resultImageView;
@property (nonatomic, strong) KLPieProgressView *progressView;
@property (nonatomic, strong) GADBannerView *topAdBannerView;
@property (nonatomic, strong) GADBannerView *bottomAdBannerView;

@property (nonatomic, strong) NSLayoutConstraint *topBannerHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomBannerHeightConstraint;

@end

@implementation KLResultViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Lifecycle
- (instancetype)init
{
    if (self = [super init]) {
        self.transition = [KLSwapTransition transition];
        self.transition.transitionOrientation = KLTransitionOrientationHorizontal;
        self.transitioningDelegate = self.transition;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareForUI];
}

- (void)prepareForUI
{
    self.view.backgroundColor = UIColor.blackColor;
    [self addSubviews];
}

- (void)addSubviews
{
    [self.view addSubview:({
        _resultImageView = [UIImageView newAutoLayoutView];
        _resultImageView.clipsToBounds = YES;
        _resultImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_resultImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResultImage:)]];
        _resultImageView;
    })];
    
    [self.view addSubview:({
        _progressView = [KLPieProgressView newAutoLayoutView];
        _progressView;
    })];
    [self.progressView constraintsCenterInSuperview];
    
    [self.view addSubview:({
        _topAdBannerView = [GADBannerView newAutoLayoutView];
        _topAdBannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
        _topAdBannerView.autoloadEnabled = YES;
        _topAdBannerView.delegate = self;
        _topAdBannerView.rootViewController = self;
        _topAdBannerView;
    })];
    
    [self.view addSubview:({
        _bottomAdBannerView = [GADBannerView newAutoLayoutView];
        _bottomAdBannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
        _bottomAdBannerView.autoloadEnabled = YES;
        _bottomAdBannerView.delegate = self;
        _bottomAdBannerView.rootViewController = self;
        _bottomAdBannerView;
    })];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_resultImageView, _topAdBannerView, _bottomAdBannerView);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_resultImageView]|" views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topAdBannerView]-16-[_resultImageView]-16-[_bottomAdBannerView]|" options:NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight views:views]];
    
    _topBannerHeightConstraint = [NSLayoutConstraint constraintHeightWithItem:_topAdBannerView constant:1]; // GADBannerViewDelegate isn't called if set 0
    _bottomBannerHeightConstraint = [NSLayoutConstraint constraintHeightWithItem:_bottomAdBannerView constant:1];
    _topBannerHeightConstraint.active = _bottomBannerHeightConstraint.active = YES;
}

- (void)setPickedAsset:(PHAsset *)pickedAsset
{
    _pickedAsset = pickedAsset;
    
    [pickedAsset originalImageProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        [self.progressView setProgress:progress animated:YES];
    } resultHandler:^(UIImage *image, NSDictionary *info) {
        [self.progressView removeFromSuperview];
        self.resultImageView.userInteractionEnabled = YES;
        self.resultImageView.image = image;
        [self.resultImageView setNeedsLayout];
    }];
}

#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    [self setAdBannerView:bannerView hidden:NO];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self setAdBannerView:bannerView hidden:YES];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    if (bannerView == self.topAdBannerView) {
        [self clickTopAdBanner];
    } else {
        [self clickBottomAdBanner];
    }
}

- (void)setAdBannerView:(GADBannerView *)bannerView hidden:(BOOL)hidden
{
    bannerView.hidden = hidden;
    NSLayoutConstraint *constraint = (bannerView == self.topAdBannerView) ? self.topBannerHeightConstraint : self.bottomBannerHeightConstraint;
    constraint.constant = hidden ? 0 : (IS_PHONE ? (IS_PORTRAIT ? 50 : 32) : 90);
    
    [UIView animateWithDefaultDuration:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Event handling
- (void)clickTopAdBanner
{
//  For Analytics
}

- (void)clickBottomAdBanner
{
//  For Analytics
}

- (void)tapResultImage:(UITapGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.dismissBlock) self.dismissBlock(self);
}

@end
