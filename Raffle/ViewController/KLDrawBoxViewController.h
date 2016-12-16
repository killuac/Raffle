//
//  KLDrawBoxViewController.h
//  Raffle
//
//  Created by Killua Liu on 7/30/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLImagePickerController.h"

@class KLMainDataController, KLDrawBoxDataController;

@interface KLDrawBoxViewController : UIViewController <KLImagePickerControllerDelegate>

+ (instancetype)viewControllerWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex;

@property (nonatomic, readonly) NSUInteger pageIndex;
@property (nonatomic, readonly) KLDrawBoxDataController *drawBoxDC;

- (void)reloadData;
- (void)randomAnPhoto:(KLAssetBlockType)resultHandler;

@end
