//
//  KLMainViewController.h
//  LuckyDraw
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLMainDataController.h"

@class KLDrawBoxViewController;

@interface KLMainViewController : UIViewController <KLDataControllerDelegate>

@property (nonatomic, readonly) KLMainDataController *dataController;
@property (nonatomic, readonly) KLDrawBoxViewController *drawBoxViewController;

@end

