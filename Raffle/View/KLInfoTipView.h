//
//  KLInfoTipView.h
//  Raffle
//
//  Created by Killua Liu on 1/21/17.
//  Copyright © 2017 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLInfoTipView : UIView

+ (instancetype)infoTipViewWithText:(NSString *)text;

+ (void)showInfoTipWithText:(NSString *)text sourceView:(UIView *)sourceView targetView:(UIView *)targetView;
+ (void)dismiss;

@end
