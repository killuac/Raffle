//
//  KLDrawPoolModel.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawPoolModel.h"

@implementation KLDrawPoolModel

@dynamic creationDate;
@dynamic drawMode;
@dynamic photos;
@dynamic assets;

+ (NSString *)entityName
{
    return @"DrawPool";
}

- (void)awakeFromInsert
{
    self.creationDate = [NSDate date];
}

- (NSUInteger)photoCount
{
    return self.assets.count;
}

- (NSArray<PHAsset *> *)assets
{
    NSArray *localIdentifiers = [self.photos.set valueForKeyPath:@"@distinctUnionOfObjects.assetLocalIdentifier"];
    PHFetchResult<PHAsset *> *results = [PHAsset fetchAssetsWithLocalIdentifiers:localIdentifiers options:nil];
    
    NSMutableArray *assetArray = [NSMutableArray array];
    [results enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        if (asset) [assetArray addObject:asset];
    }];
    
    return assetArray;
}

@end
