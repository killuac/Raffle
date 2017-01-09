//
//  KLWeakTarget.m
//  Raffle
//
//  Created by Killua Liu on 1/9/17.
//  Copyright © 2017 Syzygy. All rights reserved.
//

#import "KLWeakTarget.h"

@interface KLWeakTarget ()

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

@end

@implementation KLWeakTarget

+ (instancetype)weakTargetWithTarget:(id)target selector:(SEL)selector
{
    return [[self alloc] initWithTarget:target selector:selector];
}

- (instancetype)initWithTarget:(id)target selector:(SEL)selector
{
    if (self = [super init]) {
        self.target = target;
        self.selector = selector;
    }
    return self;
}

- (void)actionDidFire:(id)object
{
    if (self.target) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.selector withObject:object];
#pragma clang diagnostic pop
    } else {
        [object invalidate];
    }
}

@end
