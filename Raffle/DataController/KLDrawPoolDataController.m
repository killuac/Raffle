//
//  KLDrawPoolDataController.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawPoolDataController.h"

@interface KLDrawPoolDataController ()

@property (nonatomic, strong) KLDrawPoolModel *drawPool;

@end

@implementation KLDrawPoolDataController

- (instancetype)initWithModel:(KLDrawPoolModel *)model
{
    if (self = [self init]) {
        _drawPool = model;
    }
    return self;
}

- (NSUInteger)itemCount
{
    return self.drawPool.photoCount;
}

- (PHAsset *)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return self.drawPool.assets[indexPath.item];
}

@end
