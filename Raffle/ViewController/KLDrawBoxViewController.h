//
//  KLDrawBoxViewController.h
//  Raffle
//
//  Created by Killua Liu on 7/30/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLDrawBoxDataController.h"

@class KLMainDataController;

@interface KLDrawBoxViewController : UICollectionViewController

+ (instancetype)viewControllerWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex;

@property (nonatomic, assign, readonly) NSUInteger pageIndex;

@end
