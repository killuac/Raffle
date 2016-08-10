//
//  UIButton+Base.m
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright (c) 2015 Syzygy. All rights reserved.
//

#import "UIButton+Base.h"

@interface UIButton ()

@property (nonatomic, assign) KLButonStyle style;

@end


@implementation UIButton (Base)

+ (void)load
{
    KLSwizzleMethod([self class], @selector(intrinsicContentSize), @selector(swizzle_intrinsicContentSize), NO);
}

- (void)setStyle:(KLButonStyle)style
{
    objc_setAssociatedObject(self, @selector(style), @(style), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.layer.cornerRadius = KLViewDefaultCornerRadius;
    [self setBackgroundColorForState:UIControlStateNormal];
}

- (KLButonStyle)style
{
    return [objc_getAssociatedObject(self, @selector(style)) unsignedIntegerValue];
}

- (void)setIsAnimationEnabled:(BOOL)isAnimationEnabled
{
    objc_setAssociatedObject(self, @selector(isAnimationEnabled), @(isAnimationEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAnimationEnabled
{
    return [objc_getAssociatedObject(self, @selector(isAnimationEnabled)) boolValue];
}

- (void)setContentSize:(CGSize)size
{
    objc_setAssociatedObject(self, @selector(contentSize), [NSValue valueWithCGSize:size], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)contentSize
{
    return [objc_getAssociatedObject(self, @selector(contentSize)) CGSizeValue];
}

- (void)setLayout:(KLButtonLayout)layout
{
    if (KLButtonLayoutHorizontalNone == layout || !self.imageView || !self.titleLabel) return;
    
    CGFloat hInset = 5.0, vInset = 8.0, spacing;
    if (KLButtonLayoutVerticalImageUp == layout || KLButtonLayoutVerticalImageDown == layout) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        self.titleLabel.font = [UIFont defaultFont];
        [self contentSizeToFit];
        self.size = self.contentSize;
        spacing = self.height / 2 - vInset;
    } else {
        spacing = hInset * 2;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.size = self.contentSize = CGSizeMake(self.width+spacing, self.height);
    }
    
    CGFloat imageWidth = self.imageView.image.width;
    CGFloat titleWidth = self.titleLabelSize.width;
    
    switch (layout) {
        case KLButtonLayoutHorizontalImageLeft:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
            break;
            
        case KLButtonLayoutHorizontalImageRight:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth+hInset, 0, -(titleWidth+hInset));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageWidth+hInset), 0, imageWidth+hInset);
            break;
            
        case KLButtonLayoutVerticalImageUp:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth/2, spacing, -titleWidth/2);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, 0);
            self.contentEdgeInsets = UIEdgeInsetsMake(0, -hInset, 0, -hInset);  // For solve iphone5/5s issue
            break;
            
        case KLButtonLayoutVerticalImageDown:
            self.imageEdgeInsets = UIEdgeInsetsMake(-spacing, titleWidth/2, 0, -titleWidth/2);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, spacing*2, 0);
            self.contentEdgeInsets = UIEdgeInsetsMake(0, -hInset, 0, -hInset);
            break;
            
        default:
            break;
    }
}

- (CGSize)titleLabelSize
{
    return [self.titleLabel.text sizeWithFont:self.titleLabel.font];
}

// Only for vertical layout
- (void)contentSizeToFit
{
    CGFloat width = MAX(self.imageView.image.width, self.titleLabelSize.width);
    CGFloat height = self.imageView.image.height + self.titleLabelSize.height + 10.0;
    self.contentSize = CGSizeMake(width, height);
}

- (CGSize)swizzle_intrinsicContentSize
{
    if (self.imageView.image && self.titleLabel.text.length) {
        return self.contentSize;
    } else {
        return [self swizzle_intrinsicContentSize];
    }
}

- (void)setNormalTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
}

- (void)addTarget:(nullable id)target action:(SEL)action
{
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Factory method
+ (instancetype)buttonWithType:(UIButtonType)buttonType
                         title:(NSString *)title
                     imageName:(NSString *)imageName
             selectedImageName:(NSString *)selImageName
             disabledImageName:(NSString *)disabledImageName
                        layout:(KLButtonLayout)layout
{
    UIButton *button = [UIButton buttonWithType:buttonType];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTintColor:[UIColor tintColor]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor titleColor] forState:UIControlStateNormal];
    
    if (imageName.length) {
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    if (selImageName.length) {
        [button setImage:[UIImage imageNamed:selImageName] forState:UIControlStateSelected];
    }
    if (disabledImageName.length) {
        [button setImage:[UIImage imageNamed:disabledImageName] forState:UIControlStateDisabled];
    }
    
    [button sizeToFit];
    [button setLayout:layout];
    
    button.KVOController = [FBKVOController controllerWithObserver:button];
    [button.KVOController observe:button keyPaths:@[@"highlighted", @"enabled"] options:0 block:^(id observer, id object, NSDictionary *change) {
        [button setBackgroundColorForState:button.state];
    }];
    
    return button;
}

- (void)setBackgroundColorForState:(UIControlState)state
{
    switch (self.style) {
        case KLButonStyleDefault:
            if (UIControlStateHighlighted == state) {
                self.backgroundColor = [[UIColor defaultButtonColor] darkerColor];
            } else if (UIControlStateDisabled == state) {
                self.backgroundColor = [UIColor disabledButtonColor];
            } else {
                self.backgroundColor = [UIColor defaultButtonColor];
            }
            break;
            
        case KLButonStylePrimary:
            if (UIControlStateHighlighted == state) {
                self.backgroundColor = [[UIColor primaryButtonColor] darkerColor];
            } else if (UIControlStateDisabled == state) {
                self.backgroundColor = [UIColor disabledButtonColor];
            } else {
                self.backgroundColor = [UIColor primaryButtonColor];
            }
            break;
            
        case KLButonStyleDestructive:
            if (UIControlStateHighlighted == state) {
                self.backgroundColor = [[UIColor destructiveButtonColor] darkerColor];
            } else if (UIControlStateDisabled == state) {
                self.backgroundColor = [UIColor disabledButtonColor];
            } else {
                self.backgroundColor = [UIColor destructiveButtonColor];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Custom button
+ (instancetype)buttonWithTitle:(NSString *)title
{
    return [UIButton buttonWithTitle:title imageName:nil];
}

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName
{
    return [UIButton buttonWithTitle:title imageName:imageName layout:KLButtonLayoutHorizontalImageLeft];
}

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName layout:(KLButtonLayout)layout
{
    return [UIButton buttonWithTitle:title imageName:imageName selectedImageName:nil layout:layout];
}

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selImageName
{
    return [UIButton buttonWithType:UIButtonTypeCustom title:title imageName:imageName selectedImageName:selImageName disabledImageName:nil layout:KLButtonLayoutHorizontalImageLeft];
}

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selImageName layout:(KLButtonLayout)layout
{
    return [UIButton buttonWithType:UIButtonTypeCustom title:title imageName:imageName selectedImageName:selImageName disabledImageName:nil layout:layout];
}

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName disabledImageName:(NSString *)disabledImageName
{
    return [UIButton buttonWithType:UIButtonTypeCustom title:title imageName:imageName selectedImageName:nil disabledImageName:disabledImageName layout:KLButtonLayoutHorizontalImageLeft];
}

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName disabledImageName:(NSString *)disabledImageName layout:(KLButtonLayout)layout
{
    return [UIButton buttonWithType:UIButtonTypeCustom title:title imageName:imageName selectedImageName:nil disabledImageName:disabledImageName layout:layout];
}

+ (instancetype)buttonWithImageName:(NSString *)imageName
{
    return [UIButton buttonWithTitle:nil imageName:imageName];
}

+ (instancetype)buttonWithImageName:(NSString *)imageName selectedImageName:(NSString *)selImageName
{
    return [UIButton buttonWithTitle:nil imageName:imageName selectedImageName:selImageName];
}

+ (instancetype)buttonWithImageName:(NSString *)imageName disabledImageName:(NSString *)disabledImageName
{
    return [UIButton buttonWithTitle:nil imageName:imageName disabledImageName:disabledImageName];
}

#pragma mark - System button

+ (instancetype)systemButtonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:title forState:UIControlStateNormal];
    [button sizeToFit];
    
    return button;
}

+ (instancetype)linkButtonWithTitle:(NSString *)title
{
    UIButton *button = [self systemButtonWithTitle:title];
    button.tintColor = [UIColor linkButtonColor];
    button.titleLabel.font = [UIFont defaultFont];
    
    return button;
}

#pragma mark - Default, primary, destructive buttons
+ (instancetype)customButtonWithTitle:(NSString *)title
{
    return [UIButton buttonWithType:UIButtonTypeCustom title:title imageName:nil selectedImageName:nil disabledImageName:nil layout:KLButtonLayoutHorizontalNone];
}

+ (instancetype)defaultButtonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton customButtonWithTitle:title];
    [button setStyle:KLButonStyleDefault];
    [button setTitleColor:[UIColor titleColor] forState:UIControlStateNormal];
    return button;
}

+ (instancetype)primaryButtonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton customButtonWithTitle:title];
    [button setStyle:KLButonStylePrimary];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor titleColor] forState:UIControlStateDisabled];
    return button;
}

+ (instancetype)destructiveButtonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton customButtonWithTitle:title];
    [button setStyle:KLButonStyleDestructive];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor titleColor] forState:UIControlStateDisabled];
    return button;
}

@end
