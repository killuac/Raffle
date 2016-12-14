//
//  KLCameraPreviewView.m
//  Raffle
//
//  Created by Killua Liu on 12/14/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLCameraPreviewView.h"
@import AVFoundation;

@implementation KLCameraPreviewView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession *)session
{
    return self.previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
    self.previewLayer.session = session;
}

@end
