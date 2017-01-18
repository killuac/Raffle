//
//  KLPhotoView.m
//  Raffle
//
//  Created by Killua Liu on 10/26/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLPhotoView.h"

@implementation KLPhotoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = self.width / 2;
    self.layer.borderWidth = 2.0;
    self.layer.borderColor = UIColor.whiteColor.CGColor;
}

@end
