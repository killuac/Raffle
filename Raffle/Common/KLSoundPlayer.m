//
//  KLSoundPlayer.m
//  Raffle
//
//  Created by Killua Liu on 1/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLSoundPlayer.h"
@import AudioToolbox;

@implementation KLSoundPlayer

+ (void)playBubbleButtonSound
{
    // TODO: Play
}

+ (void)playStartDrawSound
{
    // TODO: Play
}

+ (void)playStopDrawSound
{
    // TODO: Play
}

+ (void)playMessageSentSound
{
    AudioServicesPlaySystemSoundWithCompletion(1004, NULL);
}

+ (void)playMessageSentAlert
{
    AudioServicesPlayAlertSoundWithCompletion(1004, NULL);
}

+ (void)playMessageReceivedSound
{
    AudioServicesPlaySystemSoundWithCompletion(1003, NULL);
}

+ (void)playMessageReceivedAlert
{
    AudioServicesPlayAlertSoundWithCompletion(1003, NULL);
}

+ (void)playMessageReceivedVibrate
{
	AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, NULL);
}

@end
