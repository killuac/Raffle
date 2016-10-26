//
//  KLPhotoViewController.h
//  Raffle
//
//  Created by Killua Liu on 9/19/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLDrawBoxTransition.h"

@interface KLPhotoViewController : UICollectionViewController

@property (nonatomic, strong, readonly) KLDrawBoxTransition *transition;

@end
