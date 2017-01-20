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

#define WALLPAPER_DIRECTORY KLURLForDocumentFile(@"Wallpaper").absoluteString

@interface KLDrawBoxModel : NSManagedObject

@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, assign) BOOL repeatMode;
@property (nonatomic, copy) NSString *wallpaperName;
@property (nonatomic, strong) NSOrderedSet<KLPhotoModel *> *photos;

@property (nonatomic, strong, readonly) NSArray<PHAsset *> *assets;
@property (nonatomic, assign, readonly) NSUInteger photoCount;
@property (nonatomic, weak, readonly) NSString *wallpaperFilePath;

@end

NS_ASSUME_NONNULL_END
