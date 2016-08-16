//
//  KLStatusBar.h
//  Raffle
//
//  Created by Killua Liu on 8/16/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLStatusBar : UIView

+ (void)showNotificationWithMessage:(NSString *)message;
+ (void)dismiss;

@end
