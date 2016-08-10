//
//  UISwitch+Base.h
//  LuckyDraw
//
//  Created by Killua Liu on 12/31/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISwitch (Base)

+ (instancetype)customSwitch;

- (void)addTarget:(id)target action:(SEL)action;

@end
