//
//  KLCameraPreviewView.m
//  Raffle
//
//  Created by Killua Liu on 12/14/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLCameraPreviewView.h"
@import AVFoundation;

@interface KLCameraPreviewView ()

@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@end

@implementation KLCameraPreviewView {
    AVCaptureSession *_session;
}

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.session = [AVCaptureSession new];
        self.sessionQueue = dispatch_queue_create("SerialSessionQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(self.sessionQueue, ^{
            [self configureSession];
        });
    }
    return self;
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

- (void)configureSession
{
    NSError *error = nil;
    
    [self.session beginConfiguration];
    
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
    if (error || !videoDeviceInput) {
        KLLog(@"AVCaptureDeviceInput init error: %@", error.localizedDescription);
        [self.session commitConfiguration];
        return;
    }
    
    if ([self.session canAddInput:videoDeviceInput]) {
        [self.session addInput:videoDeviceInput];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
            if (statusBarOrientation != UIInterfaceOrientationUnknown) {
                initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
            }
            self.previewLayer.connection.videoOrientation = initialVideoOrientation;
        });
    } else {
        KLLog(@"Could not add video device input to the session");
        [self.session commitConfiguration];
        return;
    }
    
    [self.session commitConfiguration];
}

- (void)startRunning
{
    dispatch_async(self.sessionQueue, ^{
        [self.session startRunning];
    });
}

- (void)stopRunning
{
    dispatch_async(self.sessionQueue, ^{
        [self.session stopRunning];
    });
}

@end
