//
//  UILabel+Base.h
//  Raffle
//
//  Created by Killua Liu on 1/27/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN const NSTimeInterval KLLabelScrollDelay;

@interface UILabel (Base)

+ (instancetype)labelWithText:(NSString *)text;
+ (instancetype)labelWithText:(NSString *)text attributes:(NSDictionary<NSString *, id> *)attributes;

@property (nonatomic, assign, readonly) BOOL isScrollable;
@property (nonatomic, assign, readonly) NSTimeInterval scrollDuration;

- (void)scrollIfNeeded;

@end
