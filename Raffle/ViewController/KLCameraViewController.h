//
//  KLCameraViewController.h
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLPhotoLibrary.h"

@class KLCameraViewController;

@protocol KLCameraViewControllerDelegate <NSObject>

@optional
- (void)cameraViewController:(KLCameraViewController *)cameraVC didFinishSaveImageAssets:(NSArray<PHAsset *> *)assets;
- (void)cameraViewControllerDidClose:(KLCameraViewController *)cameraVC;

@end

@interface KLCameraViewController : UIViewController

+ (void)checkAuthorization:(KLBOOLBlockType)completion;
+ (void)showAlert;

+ (instancetype)cameraViewControllerWithAlbumImage:(UIImage *)image;

@property (nonatomic, weak) id <KLCameraViewControllerDelegate> delegate;

- (void)saveImagesToPhotoAlbum:(NSArray<UIImage *> *)images completion:(KLVoidBlockType)completion;

@end
