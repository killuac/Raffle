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

@interface KLDrawBoxViewController : UICollectionViewController <KLImagePickerControllerDelegate>

+ (instancetype)viewControllerWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex;

@property (nonatomic, assign, readonly) NSUInteger pageIndex;

- (void)reloadData;
- (UIImage *)randomAnImage;

@end
