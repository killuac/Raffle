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
    NSURL *url = [NSBundle.mainBundle URLForResource:fileName withExtension:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)url, &soundID);
    AudioServicesPlaySystemSoundWithCompletion(soundID, ^{
        AudioServicesDisposeSystemSoundID(soundID);
    });
}

+ (void)playSystemSound:(NSString *)filePath
{
    SystemSoundID soundID;
    NSString *sysSoundsDir = @"/System/Library/Audio/UISounds";
    NSURL *url = [NSURL fileURLWithPath:[sysSoundsDir stringByAppendingPathComponent:filePath]];
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)url, &soundID);
    AudioServicesPlaySystemSoundWithCompletion(soundID, ^{
        AudioServicesDisposeSystemSoundID(soundID);
    });
}

+ (void)playVibrate
{
    AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, NULL);
}

+ (void)playBubbleButtonSound
{
    [self playSystemSound:@"acknowledgment_sent.caf"];
}

+ (void)playStartDrawSound
{
    [self playVibrate];
    [self playSound:@"shake"];
}

+ (void)playStopDrawSound
{
    [self playSound:@"cheer"];
}

+ (void)playReloadPhotoSound
{
    [self playSystemSound:@"nano/Alert_PassbookBalance_Haptic.caf"];
}

+ (void)playShowCameraSound

{
    [self playSystemSound:@"acknowledgment_received.caf"];
}

+ (void)playCameraShutterSound
{
    AudioServicesPlaySystemSoundWithCompletion(1108, NULL);
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
