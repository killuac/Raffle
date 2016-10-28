//
//  KLInnerShadowView.h
//  Raffle
//
//  Created by Killua Liu on 10/28/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, KLInnerShadowDirection) {
    KLInnerShadowDirectionNone   = 0,
    KLInnerShadowDirectionLeft   = (1 << 0),
    KLInnerShadowDirectionRight  = (1 << 1),
    KLInnerShadowDirectionTop    = (1 << 2),
    KLInnerShadowDirectionBottom = (1 << 3),
    KLInnerShadowDirectionAll    = 15
};

@interface KLInnerShadowView : UIView

@property (nonatomic, assign) CGFloat shadowOpacity;
@property (nonatomic, assign) CGFloat shadowRadius;
@property (nonatomic, assign) CGSize  shadowOffset;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) UIColor *shadowColor;

@property (nonatomic, assign) KLInnerShadowDirection shadowDirection;

@end
