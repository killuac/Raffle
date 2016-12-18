//
//  UIBarButtonItem+Base.m
//  Raffle
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import "UIBarButtonItem+Base.h"

@interface UIBarButtonItem ()

@property (nonatomic, copy) NSString *onImageName;
@property (nonatomic, copy) NSString *offImageName;

@end

@implementation UIBarButtonItem (Base)

+ (instancetype)barButtonItemWithButton:(UIButton *)button
{
    button.translatesAutoresizingMaskIntoConstraints = YES;
    return [[self alloc] initWithCustomView:button];
}

+ (instancetype)barButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    return [[self alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
}

+ (instancetype)barButtonItemWithImageName:(NSString *)imageName target:(id)target action:(SEL)action
{
    UIBarButtonItem *barButtonItem = [[self alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:target action:action];
    return barButtonItem;
}

+ (instancetype)barButtonItemWithOnImageName:(NSString *)onImgName offImageName:(NSString *)offImgName target:(id)target action:(SEL)action
{
    UIBarButtonItem *barButtonItem = [[self alloc] initWithImage:[UIImage imageNamed:offImgName] style:UIBarButtonItemStylePlain target:target action:action];
    barButtonItem.onImageName = onImgName;
    barButtonItem.offImageName = offImgName;
    return barButtonItem;
}

+ (instancetype)barButtonItemWithSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action
{
    return [[self alloc] initWithBarButtonSystemItem:systemItem target:target action:action];
}

+ (instancetype)backBarButtonItem
{
    return [UIBarButtonItem barButtonItemWithTitle:@"" target:nil action:nil];
}

+ (instancetype)flexibleSpaceBarButtonItem
{
    return [[self alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (NSString *)onImageName
{
    return objc_getAssociatedObject(self, @selector(onImageName));
}

- (void)setOnImageName:(NSString *)imageName
{
    objc_setAssociatedObject(self, @selector(onImageName), imageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)offImageName
{
    return objc_getAssociatedObject(self, @selector(offImageName));
}

- (void)setOffImageName:(NSString *)imageName
{
    objc_setAssociatedObject(self, @selector(offImageName), imageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isOn
{
    return [objc_getAssociatedObject(self, @selector(isOn)) boolValue];
}

- (void)setOn:(BOOL)on
{
    objc_setAssociatedObject(self, @selector(isOn), @(on), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.image = [UIImage imageNamed:on ? self.onImageName : self.offImageName];
}

@end
