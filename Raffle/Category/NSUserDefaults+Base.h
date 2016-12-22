//
//  NSUserDefaults+Base.h
//  Raffle
//
//  Created by Killua Liu on 12/22/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Base)

@property (class, nonatomic, readonly) BOOL isEmpty;
@property (class, nonatomic, assign) NSInteger flashMode;
@property (class, nonatomic, assign, getter=isFaceDetectionOn) BOOL faceDetectionOn;

@end
