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

+ (void)playSound:(NSString *)fileName
{
    SystemSoundID soundID;
    NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"m4a"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    AudioServicesPlaySystemSoundWithCompletion(soundID, NULL);
    AudioServicesDisposeSystemSoundID(soundID);
}

+ (void)playVibrate
{
    AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, NULL);
}

+ (void)playBubbleButtonSound
{
    // TODO: Play
}

+ (void)playStartDrawSound
{
    [self playVibrate];
    [self playSound:@""];
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
    [self playVibrate];
}

@end
