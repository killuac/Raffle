//
//  KLDrawPoolModel.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawPoolModel.h"

@implementation KLDrawPoolModel

- (NSUInteger )photoCount
{
    return self.assetLocalIdentifiers.count;
}

+ (NSArray *)fetchAllGroups
{
    return nil;
}

@end
