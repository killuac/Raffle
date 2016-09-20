//
//  KLDrawBoxDataController.h
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDataController.h"
#import "KLDrawBoxModel.h"

@interface KLDrawBoxDataController : KLDataController

@property (nonatomic, assign) NSUInteger pageIndex;

- (void)addPhotos:(NSArray<PHAsset *> *)assets;

@end
