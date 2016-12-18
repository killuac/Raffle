//
//  UIButton+Base.m
//  Raffle
//
//  Created by Killua Liu on 12/16/15.
//  Copyright (c) 2015 Syzygy. All rights reserved.
//

#import "UIButton+Base.h"

@interface UIButton ()

@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *selectedImageName;

@end

@implementation UIButton (Base)

+ (void)load
{
    KLClassSwizzleMethod([self class], @selector(intrinsicContentSize), @selector(swizzle_intrinsicContentSize), NO);
}

#pragma mark - Factory method
+ (instancetype)buttonWithType:(UIButtonType)buttonType
                         title:(NSString *)title
                     imageName:(NSString *)imageName
             selectedImageName:(NSString *)selImageName
             disabledImageName:(NSString *)disabledImageName
                        layout:(KLButtonLayout)layout
{
    UIButton *button = [self buttonWithType:buttonType];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTintColor:[UIColor tintColor]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor buttonTitleColor] forState:UIControlStateNormal];
    
    if (imageName.length) {
        button.imageName = imageName;
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    if (selImageName.length) {
        button.selectedImageName = selImageName;
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

- (NSString *)imageName
{
    return objc_getAssociatedObject(self, @selector(imageName));
}

- (void)setImageName:(NSString *)imageName
{
    objc_setAssociatedObject(self, @selector(imageName), imageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)selectedImageName
{
    return objc_getAssociatedObject(self, @selector(selectedImageName));
}

- (void)setSelectedImageName:(NSString *)selectedImageName
{
    objc_setAssociatedObject(self, @selector(selectedImageName), selectedImageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isChecked
{
    return [objc_getAssociatedObject(self, @selector(isChecked)) boolValue];
}

- (void)setChecked:(BOOL)checked
{
    objc_setAssociatedObject(self, @selector(isChecked), @(checked), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *imageName = checked ? self.selectedImageName : self.imageName;
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

#pragma mark - Layout
- (void)setLayout:(KLButtonLayout)layout
{
    objc_setAssociatedObject(self, @selector(layout), @(layout), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (KLButtonLayoutHorizontalNone == layout || !self.imageView || !self.titleLabel) return;
    
    CGFloat hInset = 5.0, vInset = 8.0, spacing;
    if (self.isVerticalLayout) {
        [self contentSizeToFit];
        self.size = self.contentSize;
        spacing = self.height / 2 - vInset;
    } else {
        spacing = hInset * 2;
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
            self.titleEdgeInsets = UIEdgeInsetsMake(spacing, -imageWidth, -spacing, 0);
            self.contentEdgeInsets = UIEdgeInsetsMake(0, -self.width, 0, -self.width);  // For solve iphone5/5s issue
            break;
            
        case KLButtonLayoutVerticalImageDown:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth/2, -spacing, -titleWidth/2);
            self.titleEdgeInsets = UIEdgeInsetsMake(-spacing, -imageWidth, spacing, 0);
            self.contentEdgeInsets = UIEdgeInsetsMake(0, -self.width, 0, -self.width);
            break;
            
        default:
            break;
    }
}

- (KLButtonLayout)layout
{
    return [objc_getAssociatedObject(self, @selector(layout)) unsignedIntegerValue];
}

- (BOOL)isVerticalLayout
{
    return (KLButtonLayoutVerticalImageUp == self.layout || KLButtonLayoutVerticalImageDown == self.layout);
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

#pragma mark - Style
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
    return [self buttonWithTitle:title imageName:nil];
}

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName
{
    KLButtonLayout layout = (title.length && imageName.length) ? KLButtonLayoutHorizontalImageLeft: KLButtonLayoutHorizontalNone;
    return [self buttonWithTitle:title imageName:imageName layout:layout];
}

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName layout:(KLButtonLayout)layout
{
    return [self buttonWithTitle:title imageName:imageName selectedImageName:nil layout:layout];
}

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selImageName
{
    KLButtonLayout layout = (title.length && imageName.length) ? KLButtonLayoutHorizontalImageLeft: KLButtonLayoutHorizontalNone;
    return [self buttonWithType:UIButtonTypeSystem title:title imageName:imageName selectedImageName:selImageName disabledImageName:nil layout:layout];
}

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selImageName layout:(KLButtonLayout)layout
{
    return [self buttonWithType:UIButtonTypeSystem title:title imageName:imageName selectedImageName:selImageName disabledImageName:nil layout:layout];
}

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName disabledImageName:(NSString *)disabledImageName
{
    KLButtonLayout layout = (title.length && imageName.length) ? KLButtonLayoutHorizontalImageLeft: KLButtonLayoutHorizontalNone;
    return [self buttonWithType:UIButtonTypeSystem title:title imageName:imageName selectedImageName:nil disabledImageName:disabledImageName layout:layout];
}

+ (instancetype)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName disabledImageName:(NSString *)disabledImageName layout:(KLButtonLayout)layout
{
    return [self buttonWithType:UIButtonTypeSystem title:title imageName:imageName selectedImageName:nil disabledImageName:disabledImageName layout:layout];
}

+ (instancetype)buttonWithImageName:(NSString *)imageName
{
    return [self buttonWithTitle:nil imageName:imageName];
}

+ (instancetype)buttonWithImageName:(NSString *)imageName selectedImageName:(NSString *)selImageName
{
    return [self buttonWithTitle:nil imageName:imageName selectedImageName:selImageName];
}

+ (instancetype)buttonWithImageName:(NSString *)imageName disabledImageName:(NSString *)disabledImageName
{
    return [self buttonWithTitle:nil imageName:imageName disabledImageName:disabledImageName];
}

#pragma mark - System button

+ (instancetype)systemButtonWithTitle:(NSString *)title
{
    UIButton *button = [self buttonWithType:UIButtonTypeSystem];
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
    return [self buttonWithType:UIButtonTypeCustom title:title imageName:nil selectedImageName:nil disabledImageName:nil layout:KLButtonLayoutHorizontalNone];
}

+ (instancetype)defaultButtonWithTitle:(NSString *)title
{
    UIButton *button = [self customButtonWithTitle:title];
    [button setStyle:KLButonStyleDefault];
    [button setTitleColor:[UIColor titleColor] forState:UIControlStateNormal];
    return button;
}

+ (instancetype)primaryButtonWithTitle:(NSString *)title
{
    UIButton *button = [self customButtonWithTitle:title];
    [button setStyle:KLButonStylePrimary];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor titleColor] forState:UIControlStateDisabled];
    return button;
}

+ (instancetype)destructiveButtonWithTitle:(NSString *)title
{
    UIButton *button = [self customButtonWithTitle:title];
    [button setStyle:KLButonStyleDestructive];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor titleColor] forState:UIControlStateDisabled];
    return button;
}

@end
