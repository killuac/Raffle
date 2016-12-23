//
//  KLStatusBar.h
//  Raffle
//
//  Created by Killua Liu on 8/16/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

// A subclass of UIWindow that overrides the hitTest method in order to allow tap events to pass through the window.
@interface KLStatusWindow : UIWindow @end


@interface KLStatusBar : UIView

+ (void)showWithText:(NSString *)text;
+ (void)dismiss;

@end
