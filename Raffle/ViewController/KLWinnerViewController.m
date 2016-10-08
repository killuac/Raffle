//
//  KLWinnerViewController.m
//  Raffle
//
//  Created by Killua Liu on 9/19/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLWinnerViewController.h"
@import GoogleMobileAds;

@interface KLWinnerViewController () <GADBannerViewDelegate>

@property (nonatomic, strong) GADBannerView *topADBannerView;
@property (nonatomic, strong) GADBannerView *bottomADBannerView;
@property (nonatomic, strong) UIImageView *winnerImageView;

@property (nonatomic, strong) NSLayoutConstraint *topBannerHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomBannerHeightConstraint;

@end

@implementation KLWinnerViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Lifecycle
- (instancetype)init
{
    if (self = [super init]) {
        _transition = [KLSwapTransition transitionWithGestureEnabled:NO];
        _transition.transitionOrientation = KLTransitionOrientationHorizontal;
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
    self.view.backgroundColor = [UIColor blackColor];
    [self addSubviews];
}

- (void)addSubviews
{
    [self.view addSubview:({
        _winnerImageView = [UIImageView newAutoLayoutView];
        _winnerImageView.image = self.winnerPhoto;
        _winnerImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_winnerImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWinnerPhoto:)]];
        _winnerImageView;
    })];
    
    [self.view addSubview:({
        _topADBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        _topADBannerView.translatesAutoresizingMaskIntoConstraints = NO;
        _topADBannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
        _topADBannerView.delegate = self;
        _topADBannerView.rootViewController = self;
        [_topADBannerView loadRequest:[GADRequest request]];
        _topADBannerView;
    })];
    
    [self.view addSubview:({
        _bottomADBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        _bottomADBannerView.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomADBannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
        _bottomADBannerView.autoloadEnabled = YES;
        _bottomADBannerView.delegate = self;
        _bottomADBannerView.rootViewController = self;
        _bottomADBannerView;
    })];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_winnerImageView, _topADBannerView, _bottomADBannerView);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_winnerImageView]|" views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topADBannerView]-16-[_winnerImageView]-16-[_bottomADBannerView]|" options:NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight views:views]];
    
    _topBannerHeightConstraint = [NSLayoutConstraint constraintHeightWithItem:_topADBannerView constant:0];
    _bottomBannerHeightConstraint = [NSLayoutConstraint constraintHeightWithItem:_bottomADBannerView constant:0];
    _topBannerHeightConstraint.active = _bottomBannerHeightConstraint.active = YES;
}

#pragma mark - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    [self setBottomADBannerViewHidden:NO];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self setBottomADBannerViewHidden:YES];
}

- (void)setBottomADBannerViewHidden:(BOOL)hidden
{
    self.bottomADBannerView.hidden = hidden;
    self.bottomBannerHeightConstraint.constant = hidden ? 0 : self.bottomADBannerView.height;
    [UIView animateWithDefaultDuration:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Event handling
- (void)clickTopAD:(id)sender
{
    
}

- (void)clickBottomAD:(id)sender
{
    
}

- (void)tapWinnerPhoto:(UITapGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
