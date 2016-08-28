//
//  CAAnimation+Base.h
//  Raffle
//
//  Created by Killua Liu on 8/28/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (Base)

// Need use weak self if exists retain cycle
@property (nonatomic, copy) KLVoidBlockType startBlock;
@property (nonatomic, copy) KLBOOLBlockType completionBlock;

@end
