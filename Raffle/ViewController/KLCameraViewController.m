//
//  KLCameraViewController.m
//  Raffle
//
//  Created by Killua Liu on 3/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLCameraViewController.h"
#import "KLCameraPreviewView.h"
@import AVFoundation;

@interface KLCameraViewController ()

@property (nonatomic, strong) KLCameraPreviewView *previewView;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *albumButton;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *flashModeButton;
@property (nonatomic, strong) UIButton *switchCameraButton;

@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *backCameraDevice;
@property (nonatomic, strong) AVCaptureDevice *frontCameraDevice;

@end

@implementation KLCameraViewController

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

+ (void)showAlertFromViewController:(UIViewController *)viewController
{
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:BUTTON_TITLE_CANCEL style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:BUTTON_TITLE_SETTING style:UIAlertActionStyleCancel handler:^(id action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    NSString *message = [NSString localizedStringWithFormat:MSG_ACCESS_CAMERA_SETTING, [APP_DISPLAY_NAME quotedString], [PATH_CAMERA_SETTING quotedString]];
    [[UIAlertController alertControllerWithTitle:TITLE_CAMERA message:message actions:@[setting, cancel]] show];
}

#pragma mark - Lifecycle
- (instancetype)init
{
    if (self = [super init]) {
        self.sessionQueue = dispatch_queue_create("SerialSessionQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    
    dispatch_async(self.sessionQueue, ^{
        [self.session startRunning];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeObservers];
    
    dispatch_async(self.sessionQueue, ^{
        [self.session stopRunning];
    });
}

- (void)addSubviews
{
    _previewView = [KLCameraPreviewView newAutoLayoutView];
    _previewView.session = [AVCaptureSession new];
    [self.view addSubview:_previewView];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {
        self.previewView.previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}

#pragma mark - Configure session
- (void)configureSession
{
    NSError *error = nil;
    
    [self.session beginConfiguration];
    
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    NSArray *cameraDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    [cameraDevices enumerateObjectsUsingBlock:^(AVCaptureDevice *  _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
        if (device.position == AVCaptureDevicePositionBack) {
            self.backCameraDevice = device;
            self.backCameraDevice.flashMode = AVCaptureFlashModeOff;
            self.backCameraDevice.exposureMode = AVCaptureExposureModeAutoExpose;
            self.backCameraDevice.focusMode = AVCaptureFocusModeAutoFocus;
        } else if (device.position == AVCaptureDevicePositionFront) {
            self.frontCameraDevice = device;
        }
    }];
    
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.backCameraDevice error:&error];
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
            self.previewView.previewLayer.connection.videoOrientation = initialVideoOrientation;
        });
    } else {
        KLLog(@"Could not add video device input to the session");
        [self.session commitConfiguration];
        return;
    }
    
    [self.session commitConfiguration];
}

#pragma mark - Obserers
- (void)addObservers
{
    
}

- (void)removeObservers
{
    
}

@end
