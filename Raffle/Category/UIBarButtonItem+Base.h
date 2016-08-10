//
//  UIBarButtonItem+Base.h
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Base)

+ (instancetype)barButtonItemWithButton:(UIButton *)button;
+ (instancetype)barButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (instancetype)barButtonItemWithImageName:(NSString *)imageName target:(id)target action:(SEL)action;

+ (instancetype)backBarButtonItem;
+ (instancetype)flexibleSpaceBarButtonItem;

@end
