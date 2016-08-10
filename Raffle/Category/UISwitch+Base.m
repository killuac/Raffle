//
//  UISwitch+Base.m
//  LuckyDraw
//
//  Created by Killua Liu on 12/31/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import "UISwitch+Base.h"

@implementation UISwitch (Base)

+ (instancetype)customSwitch
{
    UISwitch *switchButton = [UISwitch newAutoLayoutView];
    switchButton.onTintColor = [UIColor tintColor];
    return switchButton;
}

- (void)addTarget:(nullable id)target action:(SEL)action
{
    [self addTarget:target action:action forControlEvents:UIControlEventValueChanged];
}

@end
