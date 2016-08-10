//
//  UIToolbar+Base.m
//  LuckyDraw
//
//  Created by Killua Liu on 3/16/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "UIToolbar+Base.h"

@interface UIToolbar ()

@property (nonatomic, strong) NSArray *barButtonItems;      // Exclude flexible space bar button
@property (nonatomic, strong) NSMutableArray *separators;
@property (nonatomic, assign) BOOL isDistributed;

@end

@implementation UIToolbar (Base)

+ (void)load
{
    KLSwizzleMethod([self class], @selector(layoutSubviews), @selector(swizzle_layoutSubviews), NO);
}

+ (instancetype)toolbarWithItems:(NSArray<UIBarButtonItem *> *)items
{
    return [[self alloc] initWithItems:items isDistributed:NO separator:NO];
}

+ (instancetype)toolbarWithDistributedItems:(NSArray<UIBarButtonItem *> *)items
{
    return [self toolbarWithDistributedItems:items separator:NO];
}

+ (instancetype)toolbarWithDistributedItems:(NSArray<UIBarButtonItem *> *)items separator:(BOOL)separator
{
    return [[self alloc] initWithItems:items isDistributed:YES separator:separator];
}

- (instancetype)initWithItems:(NSArray<UIBarButtonItem *> *)items isDistributed:(BOOL)isDistributed separator:(BOOL)separator
{
    if (self = [super init]) {
        self.translucent = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.isDistributed = isDistributed;
        self.separators = [NSMutableArray array];
        self.barButtonItems = items;
        NSMutableArray *barItems = [NSMutableArray arrayWithObject:[UIBarButtonItem flexibleSpaceBarButtonItem]];
        
        [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [barItems addObject:obj];
            [barItems addObject:[UIBarButtonItem flexibleSpaceBarButtonItem]];
            
            if (idx > 0 && separator) {
                UIView *separator = [UIView newAutoLayoutView];
                separator.backgroundColor = [UIColor separatorColor];
                [self addSubview:separator];
                [self.separators addObject:separator];
            }
        }];
        
        if (!self.isDistributed) {
            [barItems removeObjectAtIndex:0];
            [barItems removeLastObject];
        }
        
        self.items = barItems;
    }
    
    return self;
}

- (void)setIsDistributed:(BOOL)isDistributed
{
    objc_setAssociatedObject(self, @selector(isDistributed), @(isDistributed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isDistributed
{
    return [objc_getAssociatedObject(self, @selector(isDistributed)) boolValue];
}

- (void)setBarButtonItems:(NSMutableArray<UIBarButtonItem *> *)barButtonItems
{
    objc_setAssociatedObject(self, @selector(barButtonItems), barButtonItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<UIBarButtonItem *> *)barButtonItems
{
    return objc_getAssociatedObject(self, @selector(barButtonItems));
}

- (void)setSeparators:(NSMutableArray<UIView *> *)separators
{
    objc_setAssociatedObject(self, @selector(separators), separators, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<UIView *> *)separators
{
    return objc_getAssociatedObject(self, @selector(separators));
}

- (void)swizzle_layoutSubviews
{
    [self swizzle_layoutSubviews];
    
    if (!self.isDistributed) return;
    
    CGFloat width = self.width / self.barButtonItems.count;
    [self.barButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.width = width;
        
        if (idx > 0 && self.separators.count) {
            CGFloat margin = 10.0f;
            [self.separators[idx-1] setFrame:CGRectMake(width * idx, margin, 0.5, self.height-margin*2)];
        }
    }];
}

- (void)setSeparatorColor:(UIColor *)color
{
    self.translucent = YES;
    
    UIView *separator = [[UIView alloc] init];
    separator.width = 1;
    separator.height = 0.5;
    separator.backgroundColor = color;
    
    UIGraphicsBeginImageContextWithOptions(separator.size, NO,  0.0f);
    [separator.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setShadowImage:image forToolbarPosition:UIBarPositionAny];
    [self setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

@end
