//
//  UIBarButtonItem+Base.h
//  Raffle
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Base)

+ (instancetype)barButtonItemWithButton:(UIButton *)button;
+ (instancetype)barButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (instancetype)barButtonItemWithImageName:(NSString *)imageName target:(id)target action:(SEL)action;
+ (instancetype)barButtonItemWithOnImageName:(NSString *)onImgName offImageName:(NSString *)offImgName target:(id)target action:(SEL)action;
+ (instancetype)barButtonItemWithSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action;

+ (instancetype)backBarButtonItem;
+ (instancetype)flexibleSpaceBarButtonItem;

@property (nonatomic, assign, getter=isOn) BOOL on;

@end
