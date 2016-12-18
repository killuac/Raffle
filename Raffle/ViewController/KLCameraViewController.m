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


#pragma mark - KLPreviewViewController
#pragma mark -
@interface KLPreviewViewController : UIViewController

@property (nonatomic, strong) KLCameraPreviewView *previewView;

@end

@implementation KLPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addSubviews];
}

- (void)addSubviews
{
    _previewView = [KLCameraPreviewView newAutoLayoutView];
    [self.view addSubview:_previewView];
    [self.previewView constraintsEqualWithSuperView];
    
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
    if (statusBarOrientation != UIInterfaceOrientationUnknown) {
        initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
    }
    self.previewView.previewLayer.connection.videoOrientation = initialVideoOrientation;
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
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {
            self.previewView.previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [CATransaction setDisableActions:NO];
        [CATransaction commit];
    }];
}

@end


#pragma mark - KLCameraViewController
#pragma mark -
@interface KLCameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) KLPreviewViewController *previewVC;
@property (nonatomic, strong) UIImage *albumImage;

@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *backCameraDevice;
@property (nonatomic, strong) AVCaptureDevice *frontCameraDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;

@property (nonatomic, assign, getter=isSessionRunning) BOOL sessionRunning;

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
    [self addPreviewViewController];
    [self addSubviews];
    
    dispatch_async(self.sessionQueue, ^{
        [self configureSession];
    });
}

- (void)addPreviewViewController
{
    self.previewVC = [KLPreviewViewController new];
    self.previewVC.previewView.session = self.session;
    [self addChildViewController:self.previewVC];
    [self.view addSubview:self.previewVC.view];
    [self.previewVC didMoveToParentViewController:self];
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
    items = @[closeButtonItem, takePhotoItem, albumButtonItem];
    UIToolbar *bottomToolbar = [UIToolbar toolbarWithItems:items];
    [self.view addSubview:bottomToolbar];
    
    // Layout subviews
    UIView *previewVCView = self.previewVC.view;
    previewVCView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(topToolbar, previewVCView, bottomToolbar);
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[previewVCView]|" options:0 views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topToolbar(40)][previewVCView][bottomToolbar(80)]|" options:NSLayoutFormatAlignAllLeading|NSLayoutFormatAlignAllTrailing views:views]];
}

- (BOOL)shouldAutorotate
{
    return NO;
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
        } else if (device.position == AVCaptureDevicePositionFront) {
            self.frontCameraDevice = device;
        }
    }];
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.backCameraDevice error:&error];
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
    
    AVCaptureVideoDataOutput *videoDataOutput = [AVCaptureVideoDataOutput new];
    if ([self.session canAddOutput:videoDataOutput]) {
        [self.session addOutput:videoDataOutput];
        [videoDataOutput setSampleBufferDelegate:self queue:self.sessionQueue];
    } else {
        KLLog(@"Could not add video data output to the session");
        [self.session commitConfiguration];
        return;
    }
    
    AVCaptureMetadataOutput *metadataOutput = [AVCaptureMetadataOutput new];
    if ([self.session canAddOutput:metadataOutput]) {
        [self.session addOutput:metadataOutput];
        if ([metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeFace] ) {
            [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
            [metadataOutput setMetadataObjectsDelegate:self queue:self.sessionQueue];
        } else {
            KLLog(@"Don't support face detection");
        }
    } else {
        KLLog(@"Could not add metadata output to the session");
        [self.session commitConfiguration];
        return;
    }
    
    [self.session commitConfiguration];
}

#pragma mark - Obserers
- (void)addObservers
{
    [self.session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:SessionRunningContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:UIApplicationWillResignActiveNotification object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:UIApplicationDidBecomeActiveNotification object:self.session];
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
    
}

- (void)sessionInterruptionEnded:(NSNotification *)notification
{
    
}

#pragma mark - Delegates
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
}

#pragma mark - Event handling
- (void)switchFlashMode:(UIBarButtonItem *)barButton
{
    barButton.on = !barButton.isOn;
}

- (void)switchCamera:(id)sender
{
    
}

- (void)switchFaceDetection:(UIBarButtonItem *)barButton
{
    barButton.on = !barButton.isOn;
}

- (void)takePhoto:(id)sender
{
    
}

- (void)switchToAlbum:(id)sender
{
    
}

- (void)closeCamera:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
