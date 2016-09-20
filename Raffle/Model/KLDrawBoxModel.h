//
//  KLDrawBoxModel.h
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "KLPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KLDrawMode) {
    KLDrawModeAttendee = 1,
    KLDrawModePrize = 2,
};

@interface KLDrawBoxModel : NSManagedObject

@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, assign) KLDrawMode drawMode;
@property (nonatomic, strong) NSOrderedSet<KLPhotoModel *> *photos;

@property (nonatomic, strong, readonly) NSArray<PHAsset *> *assets;
@property (nonatomic, assign, readonly) NSUInteger photoCount;

@end

NS_ASSUME_NONNULL_END
