//
//  PHAsset+Model.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "PHAsset+Model.h"

@implementation PHAsset (Model)

- (void)setTimestamp:(NSTimeInterval)timestamp
{
    objc_setAssociatedObject(self, @selector(timestamp), @(timestamp), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)timestamp
{
    return [objc_getAssociatedObject(self, @selector(timestamp)) doubleValue];
}

- (void)setSelected:(BOOL)selected
{
    objc_setAssociatedObject(self, @selector(isSelected), @(selected), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSelected
{
    return [objc_getAssociatedObject(self, @selector(isSelected)) boolValue];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %f", super.description, self.timestamp];
}

- (void)thumbnailImageResultHandler:(KLAssetBlockType)resultHandler
{
    [self requestImageWithSize:CGSizeMake(180, 180) progressHandler:nil resultHandler:resultHandler];
}

- (void)originalImageResultHandler:(KLAssetBlockType)resultHandler
{
    NSParameterAssert(resultHandler);
    [self requestImageWithSize:PHImageManagerMaximumSize progressHandler:nil resultHandler:resultHandler];
}

- (void)thumbnailImageProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(KLAssetBlockType)resultHandler
{
    NSParameterAssert(resultHandler);
    [self requestImageWithSize:CGSizeMake(180, 180) progressHandler:progressHandler resultHandler:resultHandler];
}

- (void)originalImageProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(KLAssetBlockType)resultHandler
{
    NSParameterAssert(resultHandler);
    [self requestImageWithSize:PHImageManagerMaximumSize progressHandler:progressHandler resultHandler:resultHandler];
}

- (void)requestImageWithSize:(CGSize)size progressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(KLAssetBlockType)resultHandler
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = NO;
    options.networkAccessAllowed = YES;
    options.version = PHImageRequestOptionsVersionCurrent;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.progressHandler = progressHandler;
    
    [[PHImageManager defaultManager] requestImageForAsset:self targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:resultHandler];
}

@end
