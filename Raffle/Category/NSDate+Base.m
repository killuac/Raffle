//
//  NSDate+Base.m
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright (c) 2015 Syzygy. All rights reserved.
//

#import "NSDate+Base.h"

@implementation NSDate (Base)

// Creating a date formatter is not a cheap operation.
// If use a formatter frequently, it is typically more efficient to cache a single instance.
static NSDateFormatter *sharedDateFormatter = nil;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDateFormatter = [[NSDateFormatter alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSCurrentLocaleDidChangeNotification
                                                          object:nil
                                                           queue:[NSOperationQueue currentQueue]
                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                          [sharedDateFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
                                                      }];
    });
}

+ (instancetype)dateWithString:(NSString *)string
{
    [sharedDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [sharedDateFormatter dateFromString:string];
}

#pragma mark - Date and time strings
- (NSString *)toString
{
    return [[self toDateString] stringByAppendingFormat:@" %@", [self toTimeString]];
}

- (NSString *)toDateString
{
    [sharedDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [sharedDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [sharedDateFormatter stringFromDate:self];
}

- (NSString *)toShortDateString
{
    [sharedDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [sharedDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [sharedDateFormatter stringFromDate:self];
}

- (NSString *)toTimeString
{
    [sharedDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [sharedDateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [sharedDateFormatter stringFromDate:self];
}

- (NSString *)toShortTimeString
{
    [sharedDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [sharedDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [sharedDateFormatter stringFromDate:self];
}

#pragma mark - Properties
- (BOOL)isToday
{
    return [[NSCalendar currentCalendar] isDateInToday:self];
}

- (BOOL)isTomorrow
{
    return [[NSCalendar currentCalendar] isDateInTomorrow:self];
}

- (BOOL)isYesterday
{
    return [[NSCalendar currentCalendar] isDateInYesterday:self];
}

- (BOOL)isWeekend
{
    return [[NSCalendar currentCalendar] isDateInWeekend:self];
}

- (BOOL)isThisYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger year = [calendar component:NSCalendarUnitYear fromDate:self];
    NSInteger currYear = [calendar component:NSCalendarUnitYear fromDate:[NSDate date]];
    return (year == currYear);
}

@end
