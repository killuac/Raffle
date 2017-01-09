//
//  NSTimer+Base.m
//  Raffle
//
//  Created by Killua Liu on 1/15/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "NSTimer+Base.h"
#import "KLWeakTarget.h"

@implementation NSTimer (Base)

+ (NSTimer *)repeatTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector
{
    KLWeakTarget *weakTarget = [KLWeakTarget weakTargetWithTarget:target selector:selector];
    NSTimer *timer = [NSTimer timerWithTimeInterval:timeInterval target:weakTarget selector:@selector(actionDidFire:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];   // Make timer contine while draggning or scrolling
    
    return timer;
}

+ (NSTimer *)scheduledRepeatTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector
{
    KLWeakTarget *weakTarget = [KLWeakTarget weakTargetWithTarget:target selector:selector];
    NSTimer *timer = [NSTimer repeatTimerWithTimeInterval:timeInterval target:weakTarget selector:@selector(actionDidFire:)];
    timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    
    return timer;
}

@end
