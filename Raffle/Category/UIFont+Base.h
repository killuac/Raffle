//
//  UIFont+Base.h
//  Raffle
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2015 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Base)

@property (class, nonatomic, readonly) UIFont *smallFont;
@property (class, nonatomic, readonly) UIFont *boldSmallFont;

@property (class, nonatomic, readonly) UIFont *mediumFont;
@property (class, nonatomic, readonly) UIFont *boldMediumFont;

@property (class, nonatomic, readonly) UIFont *largeFont;
@property (class, nonatomic, readonly) UIFont *boldLargeFont;

@property (class, nonatomic, readonly) UIFont *extraLargeFont;
@property (class, nonatomic, readonly) UIFont *boldExtraLargeFont;

@end
