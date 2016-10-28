//
//  KLDrawBoxCell.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawBoxCell.h"

@interface KLDrawBoxCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *backView1;
@property (nonatomic, strong) UIView *backView2;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) BOOL editMode;

@end

@implementation KLDrawBoxCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews
{
    // Container and image view
    [self.contentView addSubview:({
        _containerView = [UIView newAutoLayoutView];
        _containerView;
    })];
    
    [self.containerView addSubview:({
        _backView1 = [UIView newAutoLayoutView];
        _backView1.alpha = 0.5;
        _backView1.backgroundColor = [UIColor whiteColor];
        _backView1.layer.allowsEdgeAntialiasing = YES;
        _backView1.transform = CGAffineTransformMakeRotation(M_PI / 45);
        _backView1;
    })];
    
    [self.containerView addSubview:({
        _backView2 = [UIView newAutoLayoutView];
        _backView2.alpha = 0.5;
        _backView2.backgroundColor = [UIColor whiteColor];
        _backView2.layer.allowsEdgeAntialiasing = YES;
        _backView2.transform = CGAffineTransformMakeRotation(-M_PI / 45);
        _backView2;
    })];
    
    [self.containerView addSubview:({
        _imageView = [UIImageView newAutoLayoutView];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.borderWidth = 5;
        _imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _imageView;
    })];
    
    [self.backView1 constraintsEqualWithSuperView];
    [self.backView2 constraintsEqualWithSuperView];
    [self.imageView constraintsEqualWithSuperView];
    [self.containerView constraintsEqualWithSuperView];
    
    // Delete button
    CGFloat buttonHeight = IS_PAD ? 40 : 32;
    [self.contentView addSubview:({
        _deleteButton = [UIButton buttonWithImageName:@"icon_delete"];
        _deleteButton.hidden = YES;
        _deleteButton.contentMode = UIViewContentModeCenter;
        _deleteButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8];
        _deleteButton.layer.cornerRadius = buttonHeight / 2;
        _deleteButton;
    })];
    
    [self.deleteButton constraintsCenterInSuperview];
    [NSLayoutConstraint constraintWidthWithItem:self.deleteButton constant:buttonHeight].active = YES;
    [NSLayoutConstraint constraintHeightWithItem:self.deleteButton constant:buttonHeight].active = YES;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.contentView.alpha = highlighted ? 0.5 : 1.0;
}

- (void)setEditMode:(BOOL)editMode
{
    _editMode = editMode;
    
    [self.deleteButton setHidden:!editMode animated:YES];
    [UIView animateWithDefaultDuration:^{
        self.containerView.alpha = editMode ? 0.5 : 1.0;
    }];
}

- (void)configWithDrawBox:(KLDrawBoxModel *)drawBox editMode:(BOOL)editMode
{
    self.editMode = editMode;
    
    [drawBox.assets.firstObject thumbnailImageResultHandler:^(UIImage *image, NSDictionary *info) {
        self.imageView.image = image;
    }];
}

@end
