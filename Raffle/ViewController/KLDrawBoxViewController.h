//
//  KLDrawBoxViewController.h
//  Raffle
//
//  Created by Killua Liu on 7/30/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLDrawBoxDataController.h"
#import "KLImagePickerController.h"

@class KLMainDataController;

@interface KLDrawBoxViewController : UIViewController <KLImagePickerControllerDelegate>

+ (instancetype)viewControllerWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex;

@property (nonatomic, assign, readonly) NSUInteger pageIndex;
@property (nonatomic, strong, readonly) KLDrawBoxDataController *drawBoxDC;

- (void)reloadData;
- (void)randomAnPhoto:(KLAssetBlockType)resultHandler;

@end
