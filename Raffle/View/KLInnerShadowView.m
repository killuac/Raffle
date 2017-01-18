//
//  KLInnerShadowView.m
//  Raffle
//
//  Created by Killua Liu on 10/28/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLInnerShadowView.h"

#pragma mark - Class: KLInnerShadowLayer
#pragma mark -
@interface KLInnerShadowLayer : CAShapeLayer

@property (nonatomic, assign) KLInnerShadowDirection shadowDirection;

@end

@implementation KLInnerShadowLayer

- (instancetype)init
{
    if (self = [super init]) {
        self.masksToBounds = YES;
        self.needsDisplayOnBoundsChange = YES;
        self.shouldRasterize = YES;
        
        self.shadowRadius = 3.0;
        self.shadowOpacity = 1.0;
        self.shadowOffset = CGSizeMake(0.0, 0.0);
        self.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
        
        self.fillRule = kCAFillRuleEvenOdd;     // Causes the inner region in this example to NOT be filled.
        self.shadowDirection = KLInnerShadowDirectionAll;
    }
    return self;
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    
    CGFloat top = (self.shadowDirection & KLInnerShadowDirectionTop ? self.shadowRadius : 0);
    CGFloat bottom = (self.shadowDirection & KLInnerShadowDirectionBottom ? self.shadowRadius : 0);
    CGFloat left = (self.shadowDirection & KLInnerShadowDirectionLeft ? self.shadowRadius : 0);
    CGFloat right = (self.shadowDirection & KLInnerShadowDirectionRight ? self.shadowRadius : 0);
    
    CGRect largerRect = CGRectMake(self.bounds.origin.x - left, self.bounds.origin.y - top,
                                   self.bounds.size.width + left + right, self.bounds.size.height + top + bottom);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, largerRect);
    
    // Add the inner path so it's subtracted from the outer path.
    // someInnerPath could be a simple bounds rect, or maybe a rounded one for some extra fanciness.
    UIBezierPath *bezier;
    if (self.cornerRadius) {
        bezier = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.cornerRadius];
    } else {
        bezier = [UIBezierPath bezierPathWithRect:self.bounds];
    }
    CGPathAddPath(path, NULL, bezier.CGPath);
    CGPathCloseSubpath(path);
    
    self.path = path;
    
    CGPathRelease(path);
}

#pragma mark Accessors
- (void)setShadowDirection:(KLInnerShadowDirection)shadowDirection
{
    _shadowDirection = shadowDirection;
    [self setNeedsLayout];
}

- (void)setShadowColor:(CGColorRef)shadowColor
{
    [super setShadowColor:shadowColor];
    [self setNeedsLayout];
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    [super setShadowRadius:shadowRadius];
    [self setNeedsLayout];
}

- (void)setShadowOpacity:(float)shadowOpacity
{
    [super setShadowOpacity:shadowOpacity];
    [self setNeedsLayout];
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    [super setShadowOffset:shadowOffset];
    [self setNeedsLayout];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    [super setCornerRadius:cornerRadius];
    [self setNeedsLayout];
}

@end


#pragma mark - Class: KLInnerShadowView
#pragma mark -
@interface KLInnerShadowView ()

@property (nonatomic, strong) KLInnerShadowLayer *shadowLayer;

@end

@implementation KLInnerShadowView

+ (Class)layerClass
{
    return [KLInnerShadowLayer class];
}

- (KLInnerShadowLayer *)shadowLayer
{
    return (id)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;
        self.backgroundColor = UIColor.clearColor;
        
        self.shadowLayer.actions = @{ @"bounds"        : [NSNull null],
                                      @"position"      : [NSNull null],
                                      @"contents"      : [NSNull null],
                                      @"shadowColor"   : [NSNull null],
                                      @"shadowRadius"  : [NSNull null],
                                      @"shadowOffset"  : [NSNull null],
                                      @"shadowOpacity" : [NSNull null] };
    }
    return self;
}

#pragma mark - Accessors
- (KLInnerShadowDirection)shadowDirection
{
    return self.shadowLayer.shadowDirection;
}

- (void)setShadowDirection:(KLInnerShadowDirection)shadowDirection
{
    self.shadowLayer.shadowDirection = shadowDirection;
}

- (UIColor *)shadowColor
{
    return [UIColor colorWithCGColor:self.shadowLayer.shadowColor];
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    self.shadowLayer.shadowColor = shadowColor.CGColor;
}

- (CGFloat)shadowOpacity
{
    return self.shadowLayer.shadowOpacity;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    self.shadowLayer.shadowOpacity = shadowOpacity;
}

- (CGFloat)shadowRadius
{
    return self.shadowLayer.shadowRadius;
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    self.shadowLayer.shadowRadius = shadowRadius;
}

- (CGSize)shadowOffset
{
    return self.shadowLayer.shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    self.shadowLayer.shadowOffset = shadowOffset;
}

- (CGFloat)cornerRadius;
{
    return self.shadowLayer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius;
{
    self.shadowLayer.cornerRadius = cornerRadius;
}

@end
