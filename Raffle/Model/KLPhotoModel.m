//
//  KLPhotoModel.m
//  Raffle
//
//  Created by Killua Liu on 9/13/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLPhotoModel.h"
#import "KLDrawPoolModel.h"

@implementation KLPhotoModel

@dynamic assetLocalIdentifier;
@dynamic drawPool;

+ (NSString *)entityName
{
    return @"Photo";
}

@end
