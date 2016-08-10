//
//  KLAlbumViewController.h
//  Raffle
//
//  Created by Killua Liu on 3/18/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KLPhotoLibrary;

@interface KLAlbumViewController : UICollectionViewController

+ (instancetype)viewControllerWithPageIndex:(NSUInteger)pageIndex photoLibrary:(KLPhotoLibrary *)photoLibrary;

@property (nonatomic, assign, readonly) NSUInteger pageIndex;

@end
