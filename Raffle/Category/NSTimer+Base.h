//
//  NSTimer+Base.h
//  LuckyDraw
//
//  Created by Killua Liu on 1/15/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Base)

+ (NSTimer *)repeatTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector;
+ (NSTimer *)scheduledRepeatTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector;

@end
