//
//  KLDrawBoxModel.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawBoxModel.h"

@implementation KLDrawBoxModel

@dynamic creationDate;
@dynamic drawMode;
@dynamic photos;
@dynamic assets;

+ (NSString *)entityName
{
    return @"DrawBox";
}

- (void)awakeFromInsert
{
    self.creationDate = [NSDate date];
}

- (NSUInteger)photoCount
{
    return self.photos.count;
}

- (NSArray<PHAsset *> *)assets
{
    NSArray *localIdentifiers = [self.photos.array valueForKeyPath:@"@distinctUnionOfObjects.assetLocalIdentifier"];
    PHFetchResult<PHAsset *> *results = [PHAsset fetchAssetsWithLocalIdentifiers:localIdentifiers options:nil];
    
    NSMutableArray *assetArray = [NSMutableArray array];
    [results enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        if (asset) [assetArray addObject:asset];
    }];
    
    NSMutableArray *sortedAssets = [NSMutableArray array];
    [localIdentifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull localIdentifier, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger index = [assetArray indexOfObjectPassingTest:^BOOL(PHAsset *  _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            return [asset.localIdentifier isEqualToString:localIdentifier];
        }];
        if (index != NSNotFound) {
            [sortedAssets addObject:assetArray[index]];
        }
    }];
    
    return sortedAssets;
}

@end
