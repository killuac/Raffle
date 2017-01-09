//
//  KLWeakTarget.h
//  Raffle
//
//  Created by Killua Liu on 1/9/17.
//  Copyright © 2017 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLWeakTarget : NSObject

+ (instancetype)weakTargetWithTarget:(id)target selector:(SEL)selector;

- (void)actionDidFire:(id)object;

@end
