//
//  NSDate+Base.h
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright (c) 2015 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Base)

+ (instancetype)dateWithString:(NSString *)string;

@property (nonatomic, assign, readonly) BOOL isToday;
@property (nonatomic, assign, readonly) BOOL isTomorrow;
@property (nonatomic, assign, readonly) BOOL isYesterday;
@property (nonatomic, assign, readonly) BOOL isWeekend;
@property (nonatomic, assign, readonly) BOOL isThisYear;

- (NSString *)toString;
- (NSString *)toDateString;
- (NSString *)toTimeString;
- (NSString *)toShortDateString;
- (NSString *)toShortTimeString;

@end
