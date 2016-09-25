//
//  KLWinnerViewController.h
//  Raffle
//
//  Created by Killua Liu on 9/19/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLSwapTransition.h"

@interface KLWinnerViewController : UIViewController

@property (nonatomic, strong) UIImage *winnerPhoto;
@property (nonatomic, strong, readonly) KLSwapTransition *transition;

@end
