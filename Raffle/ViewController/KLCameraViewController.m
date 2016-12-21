//
//  KLCameraViewController.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLCameraViewController.h"
#import "KLCameraPreviewView.h"
#import "KLMainViewController.h"
#import "KLCircleTransition.h"
@import AVFoundation;

@interface KLCameraViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) UIImage *albumImage;
@property (nonatomic, strong) KLCameraPreviewView *previewView;
@property (nonatomic, strong) UIBarButtonItem *takePhotoButton;
@property (nonatomic, strong) UIBarButtonItem *albumButton;

@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, assign, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic, assign, getter=isFaceDetectionOn) BOOL faceDetectionOn;

@end

@implementation KLCameraViewController

static void *SessionRunningContext = &SessionRunningContext;

#pragma mark - Authorization
+ (void)checkAuthorization:(KLBOOLBlockType)completion
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (AVAuthorizationStatusNotDetermined == status) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            [self checkCameraAuthorized:granted completion:completion];
        }];
    } else {
        [self checkCameraAuthorized:(AVAuthorizationStatusAuthorized == status) completion:completion];
    }
}

+ (void)checkCameraAuthorized:(BOOL)granted completion:(KLBOOLBlockType)completion
{
    dispatch_block_t block = ^{
        if (completion) completion(granted);
    };
    
    [NSThread isMainThread] ? block() : KLDispatchMainAsync(block);
}

+ (void)showAlert
{
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:BUTTON_TITLE_CANCEL style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:BUTTON_TITLE_SETTING style:UIAlertActionStyleCancel handler:^(id action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    NSString *message = [NSString localizedStringWithFormat:MSG_ACCESS_CAMERA_SETTING, [APP_DISPLAY_NAME quotedString], [PATH_CAMERA_SETTING quotedString]];
    [[UIAlertController alertControllerWithTitle:TITLE_CAMERA message:message actions:@[setting, cancel]] show];
}

#pragma mark - Lifecycle
+ (instancetype)cameraViewControllerWithAlbumImage:(UIImage *)image
{
    return [[self alloc] initWithAlbumImage:image];
}

- (instancetype)initWithAlbumImage:(UIImage *)image
{
    if (self = [super init]) {
        self.albumImage = image;
        self.session = [AVCaptureSession new];
        self.sessionQueue = dispatch_queue_create("CameraSerialSessionQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)setTransition:(KLBaseTransition *)transition
{
    _transition = transition;
    self.transitioningDelegate = transition;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addSubviews];
    
    dispatch_async(self.sessionQueue, ^{
        [self configureSession];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addObservers];
    [self startSessionRunning];
    
    self.albumButton.enabled = ![self.presentingViewController isKindOfClass:[KLMainViewController class]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeObservers];
    [self stopSessionRunning];
}

- (void)addSubviews
{
    // Preview
    self.previewView = [KLCameraPreviewView newAutoLayoutView];
    self.previewView.session = self.session;
    [self.view addSubview:self.previewView];
    
    // Top toolbar
    UIBarButtonItem *flashButtonItem = [UIBarButtonItem barButtonItemWithOnImageName:@"icon_flash_on" offImageName:@"icon_flash_off" target:self action:@selector(switchFlashMode:)];
    UIBarButtonItem *faceButtonItem = [UIBarButtonItem barButtonItemWithOnImageName:@"icon_face_on" offImageName:@"icon_face_off" target:self action:@selector(switchFaceDetection:)];
    UIBarButtonItem *switchCameraItem = [UIBarButtonItem barButtonItemWithImageName:@"icon_camera_switcher" target:self action:@selector(switchCamera:)];
    faceButtonItem.on = YES;
    NSArray *items = @[flashButtonItem, faceButtonItem, switchCameraItem];
    UIToolbar *topToolbar = [UIToolbar toolbarWithItems:items];
    [self.view addSubview:topToolbar];
    
    // Bottom toolbar
    UIBarButtonItem *closeButtonItem = [UIBarButtonItem barButtonItemWithImageName:@"button_close" target:self action:@selector(closeCamera:)];
    UIBarButtonItem *takePhotoItem = [UIBarButtonItem barButtonItemWithImageName:@"button_camera" target:self action:@selector(takePhoto:)];
    UIImage *image = self.albumImage ?: [UIImage imageNamed:@"button_album"];
    UIBarButtonItem *albumButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(switchToAlbum:)];
    self.albumButton = albumButtonItem;
    self.takePhotoButton = takePhotoItem;
    items = @[closeButtonItem, takePhotoItem, albumButtonItem];
    UIToolbar *bottomToolbar = [UIToolbar toolbarWithItems:items];
    [self.view addSubview:bottomToolbar];
    
    // Layout subviews
    NSDictionary *views = NSDictionaryOfVariableBindings(topToolbar, _previewView, bottomToolbar);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_previewView]|" options:0 views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topToolbar(40)][_previewView][bottomToolbar(80)]|" options:NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing views:views]];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//        if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {
//            self.previewView.previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
//        }
//    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        [CATransaction setDisableActions:NO];
//        [CATransaction commit];
//    }];
//}

#pragma mark - Configure session
- (void)configureSession
{
    NSError *error = nil;
    
    [self.session beginConfiguration];
    
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
    if (error || !self.videoDeviceInput) {
        KLLog(@"AVCaptureDeviceInput init error: %@", error.localizedDescription);
        [self.session commitConfiguration];
        return;
    }
    
    if ([self.session canAddInput:self.videoDeviceInput]) {
        [self.session addInput:self.videoDeviceInput];
    } else {
        KLLog(@"Could not add video device input to the session");
        [self.session commitConfiguration];
        return;
    }
    
    self.stillImageOutput = [AVCaptureStillImageOutput new];
    if ([self.stillImageOutput.availableImageDataCodecTypes containsObject:AVVideoCodecJPEG]) {
        [self.stillImageOutput setOutputSettings:@{ AVVideoCodecKey : AVVideoCodecJPEG }];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    } else {
        KLLog(@"Could not add still image output to the session");
        [self.session commitConfiguration];
        return;
    }
    
    [self.session commitConfiguration];
    
    [self addMetadataOutput];
}

- (void)addMetadataOutput
{
    [self.session beginConfiguration];
    self.metadataOutput = [AVCaptureMetadataOutput new];
    if ([self.session canAddOutput:self.metadataOutput]) {
        [self.session addOutput:self.metadataOutput];
        if ([self.metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeFace] ) {
            [self.metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
            [self.metadataOutput setMetadataObjectsDelegate:self queue:self.sessionQueue];
        } else {
            KLLog(@"Don't support face detection");
        }
    } else {
        KLLog(@"Could not add metadata output to the session");
    }
    [self.session commitConfiguration];
}

- (void)removeMetadataOutput
{
    [self.session beginConfiguration];
    [self.session removeOutput:self.metadataOutput];
    self.metadataOutput = nil;
    [self.session commitConfiguration];
}

- (void)startSessionRunning
{
    dispatch_async(self.sessionQueue, ^{
        [self.session startRunning];
    });
}

- (void)stopSessionRunning
{
    dispatch_async(self.sessionQueue, ^{
        [self.session stopRunning];
    });
}

#pragma mark - Obserers
- (void)addObservers
{
    [self.session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.videoDeviceInput.device];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.session removeObserver:self forKeyPath:@"running" context:SessionRunningContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == SessionRunningContext) {
        self.sessionRunning = [change[NSKeyValueChangeNewKey] boolValue];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    // TODO: Set focus
}

- (void)sessionRuntimeError:(NSNotification *)notification
{
    NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
    KLLog(@"Capture session runtime error: %@", error);
    
    if ( error.code == AVErrorMediaServicesWereReset ) {
        dispatch_async(self.sessionQueue, ^{
            if (self.isSessionRunning) {
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
            }
        });
    }
}

- (void)sessionWasInterrupted:(NSNotification *)notification
{
    [self stopSessionRunning];
    [self.previewView addBlurBackground];
}

- (void)sessionInterruptionEnded:(NSNotification *)notification
{
    [self startSessionRunning];
    [self.previewView removeBlurBackground];
}

#pragma mark - Output delegates
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        KLDispatchMainAsync(^{
            [self drawRectangleWithMetadataObjects:metadataObjects];
        });
    }
}

- (void)drawRectangleWithMetadataObjects:(NSArray<AVMetadataFaceObject *> *)metadataObjects
{
    [self.previewView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataFaceObject *  _Nonnull faceObject, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect faceViewBounds = [self.previewView.previewLayer transformedMetadataObjectForMetadataObject:faceObject].bounds;
        UIView *faceRectangle = [[UIView alloc] initWithFrame:faceViewBounds];
        faceRectangle.layer.borderWidth = 1.0;
        faceRectangle.layer.borderColor = [UIColor orangeColor].CGColor;
        [self.previewView addSubview:faceRectangle];
    }];
}

#pragma mark - Event handling
- (void)switchFlashMode:(UIBarButtonItem *)barButton
{
    barButton.on = !barButton.isOn;
    BOOL isFlashOn = barButton.isOn;
    
    dispatch_async(self.sessionQueue, ^{
        AVCaptureDevice *device = self.videoDeviceInput.device;
        NSError *error = nil;
        if ([device lockForConfiguration:&error] ) {
            if (isFlashOn && [device isFlashModeSupported:AVCaptureFlashModeOn] ) {
                device.flashMode = AVCaptureFlashModeOn;
            } else {
                device.flashMode = AVCaptureFlashModeOff;
            }
            [device unlockForConfiguration];
        } else {
            KLLog(@"Could not lock device for configuration: %@", error);
        }
    });
}

- (void)switchCamera:(id)sender
{
    self.takePhotoButton.enabled = NO;
    [self.previewView addBlurBackground];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [UIView animateWithDuration:0.4 animations:^{
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.previewView cache:NO];
    }];
    
    dispatch_async(self.sessionQueue, ^{
        AVCaptureDevice *currentCameraDevice = self.videoDeviceInput.device;
        AVCaptureDevicePosition preferredPosition;
        switch (currentCameraDevice.position) {
            case AVCaptureDevicePositionUnspecified:
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
        }
        
        NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        NSUInteger index = [devices indexOfObjectPassingTest:^BOOL(AVCaptureDevice * _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
            return (device.position == preferredPosition);
        }];
        
        AVCaptureDevice *newCameraDevice = nil;
        if (index != NSNotFound) {
            newCameraDevice = devices[index];
        }
        
        if (newCameraDevice) {
            AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:newCameraDevice error:NULL];
            [self.session beginConfiguration];
            
            [self.session removeInput:self.videoDeviceInput];
            if ([self.session canAddInput:videoDeviceInput]) {
                self.videoDeviceInput = videoDeviceInput;
                [self.session addInput:videoDeviceInput];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentCameraDevice];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:newCameraDevice];
            } else {
                [self.session addInput:self.videoDeviceInput];
            }
            
            [self.session commitConfiguration];
        }
        
        KLDispatchMainAsync(^{
            self.takePhotoButton.enabled = YES;
            [self.previewView removeBlurBackground];
        });
    });
}

- (void)switchFaceDetection:(UIBarButtonItem *)barButton
{
    barButton.on = !barButton.isOn;
    self.faceDetectionOn = barButton.on;
    
    [self.previewView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    dispatch_async(self.sessionQueue, ^{
        if (self.faceDetectionOn) {
            [self addMetadataOutput];
        } else {
            [self removeMetadataOutput];
        }
        
        KLDispatchMainAsync(^{
            [self.previewView removeBlurBackground];
        });
    });
}

- (void)takePhoto:(id)sender
{
    [KLSoundPlayer playCameraShutterSound];
    [self captureStillImage];
}

- (void)captureStillImage
{
    UIView *blackView = [[UIView alloc] initWithFrame:self.previewView.bounds];
    blackView.backgroundColor = [UIColor darkBackgroundColor];
    [self.previewView addSubview:blackView];
    
    dispatch_async(self.sessionQueue, ^{
        AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(imageDataSampleBuffer);
            CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
            CIImage *image = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
            if (attachments) CFRelease(attachments);
            
        }];
    });
    
    KLDispatchMainAfter(6.0/60, ^{
        [blackView removeFromSuperview];
    });
}

- (void)switchToAlbum:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeCamera:(id)sender
{
    if ([self.presentingViewController isKindOfClass:[KLMainViewController class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    if ([self.delegate respondsToSelector:@selector(cameraViewControllerDidClose:)]) {
        [self.delegate cameraViewControllerDidClose:self];
    }
}

@end
