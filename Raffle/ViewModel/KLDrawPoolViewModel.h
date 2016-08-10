//
//  KLDrawPoolViewModel.h
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLDrawPoolModel.h"

@interface KLDrawPoolViewModel : NSObject

+ (instancetype)viewModelWithModel:(KLDrawPoolModel *)model;

@property (nonatomic, assign, readonly) NSUInteger photoCount;

- (PHAsset *)assetAtIndex:(NSUInteger)index;

@end
