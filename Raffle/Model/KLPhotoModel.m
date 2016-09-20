//
//  KLPhotoModel.m
//  Raffle
//
//  Created by Killua Liu on 9/13/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLPhotoModel.h"
#import "KLDrawBoxModel.h"

@implementation KLPhotoModel

@dynamic assetLocalIdentifier;
@dynamic drawBox;

+ (NSString *)entityName
{
    return @"Photo";
}

@end
