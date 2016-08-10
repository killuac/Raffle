//
//  KLDrawPoolViewController.h
//  Raffle
//
//  Created by Killua Liu on 7/30/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLDrawPoolViewModel.h"

@interface KLDrawPoolViewController : UICollectionViewController

+ (instancetype)viewControllerWithPageIndex:(NSUInteger)pageIndex viewModel:(KLDrawPoolViewModel *)viewModel;

@property (nonatomic, assign, readonly) NSUInteger pageIndex;

@end
