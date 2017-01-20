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
#import "KLScaleTransition.h"
#import "KLFaceViewController.h"
#import "KLAlbumViewController.h"
@import AVFoundation;
@import CoreMotion;

@interface KLCameraViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) UIImage *albumImage;
@property (nonatomic, strong) KLCameraPreviewView *previewView;
@property (nonatomic, strong) UIToolbar *topToolbar;
@property (nonatomic, strong) UIToolbar *bottomToolbar;
@property (nonatomic, strong) UIBarButtonItem *takePhotoBarButton;
@property (nonatomic, strong) UIBarButtonItem *albumBarButton;
@property (nonatomic, strong) UIBarButtonItem *closeBarButton;
@property (nonatomic, weak, readonly) UIView *albumToolbarButton;

@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) NSArray<AVMetadataFaceObject *> *metadataObjects;
@property (nonatomic, assign, getter=isSessionRunning) BOOL sessionRunning;

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

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
    
    NSThread.isMainThread ? block() : KLDispatchMainAsync(block);
}

+ (void)showAlert
{
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TITLE_CANCEL style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:TITLE_SETTINGS style:UIAlertActionStyleCancel handler:^(id action) {
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    NSString *message = [NSString localizedStringWithFormat:ALERT_ACCESS_CAMERA_SETTING, [APP_DISPLAY_NAME quotedString], [PATH_CAMERA_SETTING quotedString]];
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
        self.sessionQueue = dispatch_queue_create("com.raffle.CameraSerialSessionQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
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
    [self startAccelerometerUpdates];
    [self startSessionRunning];
    
    self.albumBarButton.enabled = ![self.presentingViewController isKindOfClass:[KLMainViewController class]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeObservers];
    [self stopAccelerometerUpdates];
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
    flashButtonItem.on = (NSUserDefaults.flashMode == AVCaptureFlashModeAuto);
    faceButtonItem.on = NSUserDefaults.isFaceDetectionOn;
    NSArray *items = @[flashButtonItem, faceButtonItem, switchCameraItem];
    self.topToolbar = [UIToolbar toolbarWithItems:items];
    [self.view addSubview:self.topToolbar];
    
    // Bottom toolbar
    self.closeBarButton = [UIBarButtonItem barButtonItemWithImageName:@"button_close" target:self action:@selector(closeCamera:)];
    self.takePhotoBarButton = [UIBarButtonItem barButtonItemWithImageName:@"button_camera" target:self action:@selector(takePhoto:)];
    UIImage *image = self.albumImage ?: [UIImage imageNamed:@"button_album"];
    self.albumBarButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(switchToAlbum:)];
    items = @[self.closeBarButton, self.takePhotoBarButton, self.albumBarButton];
    self.bottomToolbar = [UIToolbar toolbarWithItems:items];
    [self.view addSubview:self.bottomToolbar];
    
    // Layout subviews
    NSDictionary *views = NSDictionaryOfVariableBindings(_topToolbar, _previewView, _bottomToolbar);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_previewView]|" options:0 views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topToolbar(40)][_previewView][_bottomToolbar(80)]|" options:NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing views:views]];
}

- (UIView *)albumToolbarButton
{
    UIView *toolbarButton = self.bottomToolbar.subviews.lastObject;
    return [toolbarButton isKindOfClass:[UIView class]] ? toolbarButton : nil;
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
//        UIDeviceOrientation deviceOrientation = UIDevice.currentDevice.orientation;
//        if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {
//            self.previewView.previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
//        }
//    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        [CATransaction setDisableActions:NO];
//        [CATransaction commit];
//    }];
//}

// Get autual orientation even if device is locked
- (void)startAccelerometerUpdates
{
    self.motionManager = [CMMotionManager new];
    self.motionManager.accelerometerUpdateInterval = 0.2;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMAccelerometerData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            KLLog(@"Could not update accelerometer: %@", error.localizedDescription);
        } else {
            if (ABS(data.acceleration.x) < ABS(data.acceleration.y)) {
                self.videoOrientation = data.acceleration.y > 0 ? AVCaptureVideoOrientationPortraitUpsideDown : AVCaptureVideoOrientationPortrait;
            } else {
                self.videoOrientation = data.acceleration.x > 0 ? AVCaptureVideoOrientationLandscapeLeft : AVCaptureVideoOrientationLandscapeRight;
            }
        }
    }];
}

- (void)stopAccelerometerUpdates
{
    [self.motionManager stopAccelerometerUpdates];
}

#pragma mark - Configure capture session
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
    
    [self configureFlashMode];
    [self configureFaceDetection];
}

- (void)configureFlashMode
{
    AVCaptureDevice *device = self.videoDeviceInput.device;
    NSError *error = nil;
    if ([device lockForConfiguration:&error] ) {
        if (NSUserDefaults.flashMode == AVCaptureFlashModeOff && [device isFlashModeSupported:AVCaptureFlashModeOn] ) {
            device.flashMode = AVCaptureFlashModeOff;
        } else {
            device.flashMode = AVCaptureFlashModeAuto;
        }
        [device unlockForConfiguration];
    } else {
        KLLog(@"Could not lock device for configuration: %@", error);
    }
}

- (void)configureFaceDetection
{
    if (NSUserDefaults.isFaceDetectionOn) {
        [self addMetadataOutput];
    } else {
        [self removeMetadataOutput];
    }
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
    [self removeAllFaceBoxes];
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
    [self removeAllFaceBoxes];
    
    if (metadataObjects.count > 0) {
        self.metadataObjects = metadataObjects;
        KLDispatchMainAsync(^{
            [self drawFaceBoxWithMetadataObjects:metadataObjects];
        });
    }
}

- (void)drawFaceBoxWithMetadataObjects:(NSArray<AVMetadataFaceObject *> *)metadataObjects
{
    [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataFaceObject *  _Nonnull faceObject, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect faceViewBounds = [self.previewView.previewLayer transformedMetadataObjectForMetadataObject:faceObject].bounds;
        UIView *faceBox = [[UIView alloc] initWithFrame:faceViewBounds];
        faceBox.layer.borderWidth = 1.0;
        faceBox.layer.borderColor = UIColor.orangeColor.CGColor;
        [self.previewView addSubview:faceBox];
    }];
}

- (void)removeAllFaceBoxes
{
    KLDispatchMainAsync(^{
        [self.previewView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    });
}

#pragma mark - Event handling
- (void)switchFlashMode:(UIBarButtonItem *)barButton
{
    barButton.on = !barButton.isOn;
    NSUserDefaults.flashMode = barButton.isOn ? AVCaptureFlashModeAuto : AVCaptureFlashModeOff;
    
    dispatch_async(self.sessionQueue, ^{
        [self configureFlashMode];
    });
}

- (void)switchFaceDetection:(UIBarButtonItem *)barButton
{
    barButton.on = !barButton.isOn;
    NSUserDefaults.faceDetectionOn = barButton.on;
    
    [self removeAllFaceBoxes];
    dispatch_async(self.sessionQueue, ^{
        [self configureFaceDetection];
        KLDispatchMainAsync(^{
            [self.previewView removeBlurBackground];
        });
    });
}

- (void)switchCamera:(id)sender
{
    self.takePhotoBarButton.enabled = NO;
    [self removeAllFaceBoxes];
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
            self.takePhotoBarButton.enabled = YES;
            [self.previewView removeBlurBackground];
        });
    });
}

#pragma mark - Capture image
- (void)takePhoto:(id)sender
{
    [self disableToolbarButtons];
    [KLSoundPlayer playCameraShutterSound];
    [self captureStillImage];
}

- (void)enableToolbarButtons
{
    self.takePhotoBarButton.enabled = YES;
    self.albumBarButton.enabled = YES;
    self.closeBarButton.enabled = YES;
}

- (void)disableToolbarButtons
{
    self.takePhotoBarButton.enabled = NO;
    self.albumBarButton.enabled = NO;
    self.closeBarButton.enabled = NO;
}

- (void)captureStillImage
{
    UIView *blackView = [[UIView alloc] initWithFrame:self.previewView.bounds];
    blackView.backgroundColor = UIColor.darkBackgroundColor;
    [self.previewView addSubview:blackView];
    
    dispatch_async(self.sessionQueue, ^{
        AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        connection.videoOrientation = self.videoOrientation;
        
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            CFRetain(imageDataSampleBuffer);
            dispatch_async(self.sessionQueue, ^{
                NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [UIImage imageWithData:data];
                CFRelease(imageDataSampleBuffer);
                
                if (NSUserDefaults.isFaceDetectionOn) {
                    [self stopSessionRunning];
                    [self faceDetectionWithImage:image];
                } else {
                    [self saveImagesToPhotoAlbum:@[image] completion:nil];
                }
            });
        }];
    });
    
    KLDispatchMainAfter(6.0/60, ^{
        [blackView removeFromSuperview];
    });
}

- (void)faceDetectionWithImage:(UIImage *)image
{
    NSMutableArray *images = [NSMutableArray array];
    CGAffineTransform transform = KLImageOrientationIsPortrait(image.imageOrientation) ?
        CGAffineTransformMakeScale(image.width, image.height) : CGAffineTransformMakeScale(image.height, image.width);
    
    [self.metadataObjects enumerateObjectsUsingBlock:^(AVMetadataFaceObject *  _Nonnull faceObject, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect faceImageBounds = CGRectApplyAffineTransform(faceObject.bounds, transform);
        faceImageBounds = CGRectInset(faceImageBounds, -20, -20);
        
        CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, faceImageBounds);
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
        if (croppedImage) [images addObject:croppedImage];
        CGImageRelease(imageRef);
    }];
    
    KLDispatchMainAsync(^{
        if (images.count == 0) [images addObject:image];
        [self showFaceViewControllerWithImages:images];
        [self enableToolbarButtons];
    });
}

- (void)showFaceViewControllerWithImages:(NSArray *)images
{
    KLFaceViewController *faceVC = [KLFaceViewController viewControllerWithImages:images];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:faceVC];
    navController.transition = [KLScaleTransition transitionWithGestureEnabled:YES];
    navController.transition.transitionOrientation = KLTransitionOrientationHorizontal;
    [self presentViewController:navController animated:YES completion:nil];
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

#pragma mark - Public method
- (void)saveImagesToPhotoAlbum:(NSArray<UIImage *> *)images completion:(KLVoidBlockType)completion
{
    KLDispatchMainAsync(^{
        if (NSUserDefaults.isFaceDetectionOn) {
            [KLProgressHUD showActivity];
        } else {
            [self animateCaptureStillImage:images.firstObject];
        }
    });
    
    
    [KLPhotoLibrary saveImages:images completion:^(NSArray<PHAsset *> *assets) {
        [KLProgressHUD dismiss];
        if ([self.delegate respondsToSelector:@selector(cameraViewController:didFinishSaveImageAssets:)]) {
            [self.delegate cameraViewController:self didFinishSaveImageAssets:assets];
        }
        if (completion) completion();
    }];
}

- (void)animateCaptureStillImage:(UIImage *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.clipsToBounds = YES;
    imageView.frame = self.previewView.frame;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:imageView];
    
    CGSize size = CGSizeMake(20, 20);
    CGPoint center = [self.bottomToolbar convertPoint:self.albumToolbarButton.center toView:self.view];
    CGRect frame = CGRectMake(center.x - size.width/2, center.y - size.height/2, size.width, size.height);
    
    [UIView animateWithDefaultDuration:^{
        imageView.frame = frame;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
        if (self.albumImage) {
            self.albumBarButton.image = KLAlbumImageFromImage(image);
        }
        
        self.albumToolbarButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
        [UIView animateSpringWithDefaultDuration:^{
            self.albumToolbarButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self enableToolbarButtons];
        }];
    }];
}

@end
