//
//  KLDrawPoolDataController.h
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDataController.h"
#import "KLDrawPoolModel.h"

@interface KLDrawPoolDataController : KLDataController

@property (nonatomic, assign) NSUInteger pageIndex;

- (PHAsset *)assetAtIndex:(NSUInteger)index;

@end
