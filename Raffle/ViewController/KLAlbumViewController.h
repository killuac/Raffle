//
//  KLAlbumViewController.h
//  Raffle
//
//  Created by Killua Liu on 3/18/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN UIImage *KLAlbumImageFromImage(UIImage *image);

@class KLPhotoLibrary;

@interface KLAlbumViewController : UICollectionViewController

+ (instancetype)viewControllerWithPhotoLibrary:(KLPhotoLibrary *)photoLibrary atPageIndex:(NSUInteger)pageIndex;

@property (nonatomic, readonly) NSUInteger pageIndex;

- (void)saveImagesToPhotoAlbum:(NSArray<UIImage *> *)images completion:(KLVoidBlockType)completion;

@end
