//
//  NSDate+Base.h
//  Raffle
//
//  Created by Killua Liu on 12/16/15.
//  Copyright (c) 2015 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Base)

+ (instancetype)dateWithString:(NSString *)string;

@property (nonatomic, readonly) BOOL isToday;
@property (nonatomic, readonly) BOOL isTomorrow;
@property (nonatomic, readonly) BOOL isYesterday;
@property (nonatomic, readonly) BOOL isWeekend;
@property (nonatomic, readonly) BOOL isThisYear;

- (NSString *)toString;
- (NSString *)toDateString;
- (NSString *)toTimeString;
- (NSString *)toShortDateString;
- (NSString *)toShortTimeString;

@end
