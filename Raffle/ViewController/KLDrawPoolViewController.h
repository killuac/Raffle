//
//  KLDrawPoolViewController.h
//  Raffle
//
//  Created by Killua Liu on 7/30/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLDrawPoolDataController.h"

@class KLMainDataController;

@interface KLDrawPoolViewController : UICollectionViewController

+ (instancetype)viewControllerWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex;

@property (nonatomic, assign, readonly) NSUInteger pageIndex;

@end
