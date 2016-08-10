//
//  JSONModel+Base.h
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright (c) 2016 Syzygy. All rights reserved.
//

@import JSONModel;
#import "NSArray+Model.h"

@interface JSONModel (Base)

@property (nonatomic, assign) BOOL isSelected;

+ (instancetype)model;
+ (instancetype)modelWithString:(NSString *)string;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
+ (instancetype)modelWithData:(NSData *)data;

@end
