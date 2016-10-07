//
//  KLWinnerViewController.m
//  Raffle
//
//  Created by Killua Liu on 9/19/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLWinnerViewController.h"

@interface KLWinnerViewController ()

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
    [self addTapGesture];
}

- (void)addSubviews
{
    
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Event handling
- (void)clickTopAD:(id)sender
{
    
}

- (void)clickBottomAD:(id)sender
{
    
}

@end
