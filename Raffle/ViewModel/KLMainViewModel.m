//
//  KLMainViewModel.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLMainViewModel.h"
#import "KLDrawPoolModel.h"

@interface KLMainViewModel ()

@property (nonatomic, strong) NSArray <KLDrawPoolModel *> *drawPools;

@end

@implementation KLMainViewModel

- (NSUInteger)drawPoolCount
{
    return self.drawPools.count;
}

- (BOOL)isPageScrollEnabled
{
    return self.drawPoolCount > 0;
}

- (KLDrawPoolViewModel *)drawPoolViewModelAtIndex:(NSUInteger)index
{
    KLDrawPoolModel *model = self.drawPools[index];
    return [KLDrawPoolViewModel viewModelWithModel:model];
}

@end
