//
//  KLDrawPoolModel.h
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "KLPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KLDrawMode) {
    KLDrawModePrize = 1,
    KLDrawModeAttendee
};

@interface KLDrawPoolModel : NSManagedObject

@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, assign) KLDrawMode drawMode;
@property (nonatomic, strong) NSSet<KLPhotoModel *> *photos;

@property (nonatomic, strong, readonly) NSArray<PHAsset *> *assets;
@property (nonatomic, assign, readonly) NSUInteger photoCount;

@end


@interface KLDrawPoolModel (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(KLPhotoModel *)value;
- (void)removePhotosObject:(KLPhotoModel *)value;
- (void)addPhotos:(NSSet<KLPhotoModel *> *)values;
- (void)removePhotos:(NSSet<KLPhotoModel *> *)values;

@end

NS_ASSUME_NONNULL_END
