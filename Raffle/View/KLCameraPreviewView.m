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
@property (nonatomic, strong) UIVisualEffectView *blurMaskView;

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

#pragma mark - Life cycle
+ (instancetype)newViewWithSession
{
    KLCameraPreviewView *view = [self newAutoLayoutView];
    view.session = [AVCaptureSession new];
    view.sessionQueue = dispatch_queue_create("com.raffle.PreviewSerialSessionQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(view.sessionQueue, ^{
        [view configureSession];
    });
    
    KLDispatchMainAsync(^{
        [view addObservers];
    });
    
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return self;
}

#pragma mark - Observers
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [self removeObservers];
}

- (void)orientationDidChange:(NSNotification *)notification
{
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (statusBarOrientation != UIInterfaceOrientationUnknown) {
        self.previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
    }
}

#pragma mark - configure session
- (void)configureSession
{
    NSError *error = nil;
    
    [self.session beginConfiguration];
    
    self.session.sessionPreset = AVCaptureSessionPresetLow;
    AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!cameraDevice) {
        dispatch_suspend(self.sessionQueue);
        [self removeObservers];
        [self.session commitConfiguration];
        return;
    }
    
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
    if (error || !videoDeviceInput) {
        KLLog(@"AVCaptureDeviceInput init error: %@", error.localizedDescription);
        [self.session commitConfiguration];
        return;
    }
    
    if ([self.session canAddInput:videoDeviceInput]) {
        [self.session addInput:videoDeviceInput];
        KLDispatchMainAsync(^{
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

- (void)startRunning:(KLVoidBlockType)completion
{
    if (!self.sessionQueue) return;
    dispatch_async(self.sessionQueue, ^{
        [self.session startRunning];
        KLDispatchMainAsync(^{
            [self removeBlurBackground];
            if (completion) completion();
        });
    });
}

- (void)stopRunning:(KLVoidBlockType)completion
{
    if (!self.sessionQueue) return;
    dispatch_async(self.sessionQueue, ^{
        [self.session stopRunning];
        KLDispatchMainAsync(^{
            [self addBlurBackground];
            if (completion) completion();
        });
    });
}

@end
