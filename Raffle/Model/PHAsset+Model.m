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
    [self thumbnailImageProgressHandler:nil resultHandler:resultHandler];
}

- (void)originalImageResultHandler:(KLAssetBlockType)resultHandler
{
    NSParameterAssert(resultHandler);
    [self originalImageProgressHandler:nil resultHandler:resultHandler];
}

- (void)thumbnailImageProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(KLAssetBlockType)resultHandler
{
    NSParameterAssert(resultHandler);
    CGSize targetSize = CGSizeMake(SCREEN_WIDTH * SCREEN_SCALE / 4, SCREEN_HEIGHT * SCREEN_SCALE / 4);
    [self requestImageWithTargetSize:targetSize progressHandler:progressHandler resultHandler:resultHandler];
}

- (void)originalImageProgressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(KLAssetBlockType)resultHandler
{
    NSParameterAssert(resultHandler);
    [self requestImageWithTargetSize:PHImageManagerMaximumSize progressHandler:progressHandler resultHandler:resultHandler];
}

- (void)requestImageWithTargetSize:(CGSize)targetSize progressHandler:(PHAssetImageProgressHandler)progressHandler resultHandler:(KLAssetBlockType)resultHandler
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = NO;
    options.networkAccessAllowed = YES;
    options.version = PHImageRequestOptionsVersionOriginal;
    options.resizeMode = PHImageRequestOptionsResizeModeNone;   // For high quality image
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.progressHandler = progressHandler;
    
    [[PHImageManager defaultManager] requestImageForAsset:self targetSize:targetSize contentMode:PHImageContentModeDefault options:options resultHandler:resultHandler];
}

@end
