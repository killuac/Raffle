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
    KLDrawModeAttendee = 1,
    KLDrawModePrize = 2,
};

@interface KLDrawPoolModel : NSManagedObject

@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, assign) KLDrawMode drawMode;
@property (nonatomic, strong) NSOrderedSet<KLPhotoModel *> *photos;

@property (nonatomic, strong, readonly) NSArray<PHAsset *> *assets;
@property (nonatomic, assign, readonly) NSUInteger photoCount;

@end


@interface KLDrawPoolModel (CoreDataGeneratedAccessors)

- (void)insertObject:(KLPhotoModel *)value inPhotosAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPhotosAtIndex:(NSUInteger)idx;
- (void)insertPhotos:(NSArray<KLPhotoModel *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePhotosAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPhotosAtIndex:(NSUInteger)idx withObject:(KLPhotoModel *)value;
- (void)replacePhotosAtIndexes:(NSIndexSet *)indexes withPhotos:(NSArray<KLPhotoModel *> *)values;
- (void)addPhotosObject:(KLPhotoModel *)value;
- (void)removePhotosObject:(KLPhotoModel *)value;
- (void)addPhotos:(NSOrderedSet<KLPhotoModel *> *)values;
- (void)removePhotos:(NSOrderedSet<KLPhotoModel *> *)values;

@end

NS_ASSUME_NONNULL_END
