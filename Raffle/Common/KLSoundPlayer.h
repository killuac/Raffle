//
//  KLSoundPlayer.h
//  Raffle
//
//  Created by Killua Liu on 1/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

@import Foundation;

@interface KLSoundPlayer : NSObject

+ (void)playBubbleButtonSound;
+ (void)playStartDrawSound;
+ (void)playStopDrawSound;
+ (void)playCameraShutterSound;

+ (void)playMessageSentSound;
+ (void)playMessageSentAlert;
+ (void)playMessageReceivedSound;
+ (void)playMessageReceivedAlert;

+ (void)playMessageReceivedVibrate;

@end
