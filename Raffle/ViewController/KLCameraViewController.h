//
//  KLCameraViewController.h
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLCameraViewController : UIImagePickerController

+ (void)checkAuthorization:(KLVoidBlockType)completion;

@end
