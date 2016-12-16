//
//  KLCameraPreviewView.h
//  Raffle
//
//  Created by Killua Liu on 12/14/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession, AVCaptureVideoPreviewLayer;

@interface KLCameraPreviewView : UIView

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;

- (void)startRunning;
- (void)stopRunning;

@end
