//
//  UIToolbar+Base.h
//  Raffle
//
//  Created by Killua Liu on 3/16/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIToolbar (Base)

+ (instancetype)toolbarWithItems:(NSArray<UIBarButtonItem *> *)items;
+ (instancetype)toolbarWithDistributedItems:(NSArray<UIBarButtonItem *> *)items;   // No separator by default
+ (instancetype)toolbarWithDistributedItems:(NSArray<UIBarButtonItem *> *)items separator:(BOOL)separator;  // Distribution fill equally

- (void)setTopBorderColor:(UIColor *)color;

@end
