//
//  KLCameraPreviewView.m
//  Raffle
//
//  Created by Killua Liu on 12/14/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLCameraPreviewView.h"
#import "KLCameraViewController.h"
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

+ (instancetype)newViewWithSession
{
    KLCameraPreviewView *view = [self newAutoLayoutView];
    [KLCameraViewController checkAuthorization:^(BOOL granted) {
        if (granted) {
            view.session = [AVCaptureSession new];
            view.sessionQueue = dispatch_queue_create("SerialSessionQueue", DISPATCH_QUEUE_SERIAL);
            
            dispatch_async(view.sessionQueue, ^{
                [view configureSession];
            });
            
            KLDispatchMainAsync(^{
                [view addObservers];
                [view startRunning];
            });
        }
    }];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return self;
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientationDidChange:(NSNotification *)notification
{
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (statusBarOrientation != UIInterfaceOrientationUnknown) {
        self.previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
    }
}

- (void)configureSession
{
    NSError *error = nil;
    
    [self.session beginConfiguration];
    
    self.session.sessionPreset = AVCaptureSessionPresetLow;
    AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
    if (error || !videoDeviceInput) {
        KLLog(@"AVCaptureDeviceInput init error: %@", error.localizedDescription);
        [self.session commitConfiguration];
        dispatch_suspend(self.sessionQueue);
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
    if (!self.session) return;
    dispatch_async(self.sessionQueue, ^{
        [self.session startRunning];
        KLDispatchMainAsync(^{
            self.transform = CGAffineTransformMakeScale(CGFLOAT_MIN, CGFLOAT_MIN);
            [UIView animateWithDefaultDuration:^{
                self.transform = CGAffineTransformIdentity;
            }];
        });
    });
}

- (void)stopRunning
{
    if (!self.session) return;
    dispatch_async(self.sessionQueue, ^{
        [self.session stopRunning];
    });
}

@end
