//
//  KLDrawPoolModel.h
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

@import JSONModel;
#import "PHAsset+Model.h"

typedef NS_ENUM(NSUInteger, KLDrawMode) {
    KLDrawModePrize,
    KLDrawModeAttendee
};

@interface KLDrawPoolModel : JSONModel

@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, assign) KLDrawMode drawMode;
@property (nonatomic, strong) NSArray<NSString *> *assetLocalIdentifiers;

@property (nonatomic, strong, readonly) NSArray<PHAsset *> *assets;
@property (nonatomic, assign, readonly) NSUInteger photoCount;

+ (NSArray<KLDrawPoolModel *> *)fetchAllGroups;

@end
