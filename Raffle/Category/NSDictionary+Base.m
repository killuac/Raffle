//
//  NSDictionary+Base.m
//  Raffle
//
//  Created by Killua Liu on 11/2/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "NSDictionary+Base.h"

@implementation NSDictionary (Base)

- (NSMutableDictionary *)mutableDeepCopy
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (id key in self.allKeys) {
        id oneValue = [self valueForKey:key];
        id oneCopy = nil;
        if ([oneValue respondsToSelector:@selector(mutableDeepCopy)]) {
            oneCopy = [oneValue mutableDeepCopy];
        } else if ([oneValue respondsToSelector:@selector(mutableCopy)]) {
            oneCopy = [oneValue mutableCopy];
        } else if (oneCopy == nil) {
            oneCopy = [oneValue copy];
        }
        [dictionary setObject:oneCopy forKey:key];
    }
    return dictionary;
    
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
//    NSMutableDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    return dictionary;
}

@end
