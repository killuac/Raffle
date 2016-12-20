//
//  KLCameraViewController.h
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KLBaseTransition;

@interface KLCameraViewController : UIViewController

+ (void)checkAuthorization:(KLBOOLBlockType)completion;
+ (void)showAlert;

+ (instancetype)cameraViewControllerWithAlbumImage:(UIImage *)image;

@property (nonatomic, strong) KLBaseTransition *transition;

@end
