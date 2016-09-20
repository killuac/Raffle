//
//  KLPhotoModel.h
//  Raffle
//
//  Created by Killua Liu on 9/13/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "PHAsset+Model.h"

NS_ASSUME_NONNULL_BEGIN

@class KLDrawBoxModel;

@interface KLPhotoModel : NSManagedObject

@property (nonatomic, strong) NSString *assetLocalIdentifier;
@property (nonatomic, strong) KLDrawBoxModel *drawBox;

@end

NS_ASSUME_NONNULL_END
