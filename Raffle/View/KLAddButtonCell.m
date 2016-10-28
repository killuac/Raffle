//
//  KLAddButtonCell.m
//  Raffle
//
//  Created by Killua Liu on 10/28/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLAddButtonCell.h"
#import "KLInnerShadowView.h"

@interface KLAddButtonCell ()

@property (nonatomic, strong) UIImageView *addImageView;

@end

@implementation KLAddButtonCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews
{
    [self.contentView addSubview:({
        KLInnerShadowView *shadowView = [[KLInnerShadowView alloc] initWithFrame:self.bounds];
        shadowView;
    })];
    
    [self.contentView addSubview:({
        _addImageView = [UIImageView newAutoLayoutView];
        _addImageView.contentMode = UIViewContentModeCenter;
        _addImageView.image = [UIImage imageNamed:@"icon_cv_add"];
        _addImageView;
    })];
    
    [self.addImageView constraintsEqualWithSuperView];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.contentView.alpha = highlighted ? 0.5 : 1.0;
}

@end
