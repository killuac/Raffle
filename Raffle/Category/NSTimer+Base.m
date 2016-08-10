//
//  NSTimer+Base.m
//  LuckyDraw
//
//  Created by Killua Liu on 1/15/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "NSTimer+Base.h"

@implementation NSTimer (Base)

+ (NSTimer *)repeatTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:timeInterval target:target selector:selector userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];   // Make timer contine while draggning or scrolling
    
    return timer;
}

+ (NSTimer *)scheduledRepeatTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector
{
    NSTimer *timer = [NSTimer repeatTimerWithTimeInterval:timeInterval target:target selector:selector];
    timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    
    return timer;
}

@end
