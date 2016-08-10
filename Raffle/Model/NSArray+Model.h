//
//  NSArray+Model.h
//  LuckyDraw
//
//  Created by Killua Liu on 1/27/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Model)

- (NSData *)toJSONData;
- (NSString *)toJSONString;

@end
