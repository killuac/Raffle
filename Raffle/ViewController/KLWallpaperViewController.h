//
//  KLWallpaperViewController.h
//  Raffle
//
//  Created by Killua Liu on 1/11/17.
//  Copyright © 2017 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KLWallpaperViewController;

@protocol KLWallpaperViewControllerDelegate <NSObject>

@optional
- (void)wallpaperViewController:(KLWallpaperViewController *)wallpaperVC didChooseWallpaperImageName:(NSString *)imageName;

@end

@interface KLWallpaperViewController : UICollectionViewController

@property (nonatomic, weak) id <KLWallpaperViewControllerDelegate> delegate;

@end


@interface KLWallpaperPopoverBackgroundView : UIPopoverBackgroundView @end
