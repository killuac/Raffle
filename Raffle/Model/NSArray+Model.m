//
//  NSArray+Model.m
//  LuckyDraw
//
//  Created by Killua Liu on 1/27/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "NSArray+Model.h"

@implementation NSArray (Model)

- (NSData *)toJSONData
{
    NSData *jsonData = nil;
    @try {
        NSArray *dictArray = [JSONModel arrayOfDictionariesFromModels:self];
        jsonData = [NSJSONSerialization dataWithJSONObject:dictArray options:kNilOptions error:nil];
    }
    @catch (NSException *exception) {
#ifdef DEBUG
        NSLog(@"EXCEPTION: %@", exception.description);
#endif
    }
    
    return jsonData;
}

- (NSString *)toJSONString
{
    return [[NSString alloc] initWithData: [self toJSONData] encoding: NSUTF8StringEncoding];
}

@end
