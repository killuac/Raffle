//
//  KLCameraViewController.h
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLCameraViewController : UIViewController

+ (void)checkAuthorization:(KLBOOLBlockType)completion;
+ (void)showAlert;

+ (instancetype)cameraViewControllerWithAlbumImage:(UIImage *)image;

@end
