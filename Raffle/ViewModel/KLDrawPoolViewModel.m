//
//  KLDrawPoolViewModel.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawPoolViewModel.h"

@interface KLDrawPoolViewModel ()

@property (nonatomic, strong) KLDrawPoolModel *drawPool;

@end

@implementation KLDrawPoolViewModel

+ (instancetype)viewModelWithModel:(KLDrawPoolModel *)model
{
    return [[self alloc] initWithModel:model];
}

- (instancetype)initWithModel:(KLDrawPoolModel *)model
{
    if (self = [super init]) {
        _drawPool = model;
    }
    return self;
}

- (NSUInteger)photoCount
{
    return self.drawPool.photoCount;
}

- (PHAsset *)assetAtIndex:(NSUInteger)index
{
    return self.drawPool.assets[index];
}

@end
