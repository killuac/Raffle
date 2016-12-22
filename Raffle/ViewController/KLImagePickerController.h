//
//  KLImagePickerController.h
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLPhotoLibrary.h"
#import "KLAlbumViewController.h"

@class KLImagePickerController, KLBaseTransition;

@protocol KLImagePickerControllerDelegate <NSObject>

@optional
- (void)imagePickerController:(KLImagePickerController *)picker didFinishPickingImageAssets:(NSArray<PHAsset *> *)assets;
- (void)imagePickerControllerDidClose:(KLImagePickerController *)picker;

@end


@interface KLImagePickerController : UIViewController

+ (void)checkAuthorization:(KLVoidBlockType)completion;

+ (instancetype)imagePickerController;

@property (nonatomic, weak) id <KLImagePickerControllerDelegate> delegate;

@end
