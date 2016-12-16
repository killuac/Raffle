//
//  KLDrawBoxCell.h
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLDrawBoxModel.h"

@interface KLDrawBoxCell : UICollectionViewCell

@property (nonatomic, readonly) UIButton *deleteButton;

- (void)configWithDrawBox:(KLDrawBoxModel *)drawBox editMode:(BOOL)editMode;

@end
