//
//  NSUserDefaults+Base.h
//  Raffle
//
//  Created by Killua Liu on 12/22/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Base)

@property (class, nonatomic, assign, getter=hasLaunchedOnce) BOOL launchedOnce;
@property (class, nonatomic, assign, getter=hasShownShakeTip) BOOL shownShakeTip;
@property (class, nonatomic, assign, getter=hasShownReloadTip) BOOL shownReloadTip;
@property (class, nonatomic, assign, getter=hasShownDeleteTip) BOOL shownDeleteTip;
@property (class, nonatomic, assign, getter=hasShownFaceDetectionTip) BOOL shownFaceDetectionTip;

@property (class, nonatomic, assign) NSInteger flashMode;
@property (class, nonatomic, assign, getter=isFaceDetectionOn) BOOL faceDetectionOn;

@end
