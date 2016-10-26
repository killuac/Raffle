//
//  KLDrawBoxCell.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawBoxCell.h"

@interface KLDrawBoxCell ()

@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) UIImageView *imageView3;
@property (nonatomic, strong) UIView *imageContainerView;

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
    // Image container view
    [self.contentView addSubview:({
        _imageContainerView = [UIView newAutoLayoutView];
        _imageContainerView;
    })];
    
    [self.imageContainerView constraintsEqualWithSuperView];
    
    // Thumbnail image view
    [self.imageContainerView addSubview:({
        _imageView1 = [UIImageView newAutoLayoutView];
        _imageView1.contentMode = UIViewContentModeScaleAspectFill;
        _imageView1.clipsToBounds = YES;
        _imageView1;
    })];
    
    [self.imageContainerView addSubview:({
        _imageView2 = [UIImageView newAutoLayoutView];
        _imageView2.contentMode = UIViewContentModeScaleAspectFill;
        _imageView2.clipsToBounds = YES;
        _imageView2.transform = CGAffineTransformMakeRotation(M_PI / 45);
        _imageView2;
    })];
    
    [self.imageContainerView addSubview:({
        _imageView3 = [UIImageView newAutoLayoutView];
        _imageView3.contentMode = UIViewContentModeScaleAspectFill;
        _imageView3.clipsToBounds = YES;
        _imageView3.transform = CGAffineTransformMakeRotation(-M_PI / 45);
        _imageView3;
    })];
    
    [self.imageView1 constraintsEqualWithSuperView];
    [self.imageView2 constraintsEqualWithSuperView];
    [self.imageView3 constraintsEqualWithSuperView];
    [self.imageContainerView bringSubviewToFront:self.imageView1];
    
    // Delete button
    CGFloat buttonHeight = 32;
    [self.contentView addSubview:({
        _deleteButton = [UIButton buttonWithImageName:@"icon_delete"];
        _deleteButton.hidden = YES;
        _deleteButton.contentMode = UIViewContentModeCenter;
        _deleteButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8];
        _deleteButton.layer.cornerRadius = buttonHeight / 2;
        _deleteButton;
    })];
    
    [NSLayoutConstraint constraintWidthWithItem:self.deleteButton constant:buttonHeight].active = YES;
    [NSLayoutConstraint constraintHeightWithItem:self.deleteButton constant:buttonHeight].active = YES;
    [self.deleteButton constraintsCenterInSuperview];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.contentView.alpha = highlighted ? 0.5 : 1.0;
}

- (void)setEditMode:(BOOL)editMode
{
    _editMode = editMode;
    
    if (editMode) {
        self.deleteButton.hidden = NO;
        self.deleteButton.alpha = 0.0;
    }
    
    [UIView animateWithDefaultDuration:^{
        self.imageContainerView.alpha = editMode ? 0.5 : 1.0;
        self.deleteButton.alpha = editMode ? 1.0 : 0.0;
    } completion:^(BOOL finished) {
        self.deleteButton.hidden = !editMode;
    }];
}

- (void)configWithDrawBox:(KLDrawBoxModel *)drawBox editMode:(BOOL)editMode
{
    self.editMode = editMode;
    
    [drawBox.assets.firstObject thumbnailImageResultHandler:^(UIImage *image, NSDictionary *info) {
        self.imageView1.image = image;
    }];
    
    if (drawBox.assets.count <= 1) return;
    [drawBox.assets[1] thumbnailImageResultHandler:^(UIImage *image, NSDictionary *info) {
        self.imageView2.image = image;
    }];
    
    if (drawBox.assets.count <= 2) return;
    [drawBox.assets[2] thumbnailImageResultHandler:^(UIImage *image, NSDictionary *info) {
        self.imageView3.image = image;
    }];
}

@end
