//
//  CAAnimation+Base.m
//  Raffle
//
//  Created by Killua Liu on 8/28/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "CAAnimation+Base.h"

@implementation CAAnimation (Base)

+ (void)load
{
    KLClassSwizzleMethod([self class], @selector(init), @selector(swizzle_init), NO);
}

- (instancetype)swizzle_init
{
    id animation = [self swizzle_init];
    [animation setDelegate:animation];
    return animation;
}

- (void)setStartBlock:(KLVoidBlockType)startBlock
{
    objc_setAssociatedObject(self, @selector(startBlock), startBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (KLVoidBlockType)startBlock
{
    return objc_getAssociatedObject(self, @selector(startBlock));
}

- (void)setCompletionBlock:(KLBOOLBlockType)completionBlock
{
    objc_setAssociatedObject(self, @selector(completionBlock), completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (KLBOOLBlockType)completionBlock
{
    return objc_getAssociatedObject(self, @selector(completionBlock));
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.startBlock) {
        self.startBlock();
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.completionBlock) {
        self.completionBlock(flag);
    }
}

@end
