//
//  KLDrawBoxViewController.m
//  Raffle
//
//  Created by Killua Liu on 7/30/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawBoxViewController.h"
#import "KLMainViewController.h"
#import "KLDrawBoxDataController.h"

@interface KLDrawBoxViewController () <KLDataControllerDelegate>

@property (nonatomic, strong) KLMainDataController *mainDC;
@property (nonatomic, weak, readonly) KLMainViewController *mainVC;

@end

@implementation KLDrawBoxViewController

#pragma mark - Lifecycle
+ (instancetype)viewControllerWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex
{
    return [[self alloc] initWithDataController:dataController atPageIndex:pageIndex];
}

- (instancetype)initWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex
{
    if (self = [super init]) {
        _mainDC = dataController;
        _dataController = [dataController drawBoxDataControllerAtIndex:pageIndex];
        _dataController.delegate = self;
    }
    return self;
}

- (NSUInteger)pageIndex
{
    return self.dataController.pageIndex;
}

- (KLMainViewController *)mainVC
{
    return (id)self.parentViewController.parentViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
    [self addObservers];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addObservers];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeObservers];
}

#pragma mark - Observers
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    self.KVOController = [FBKVOController controllerWithObserver:self];
    [self.KVOController observe:self.dataController keyPath:NSStringFromSelector(@selector(remainingAssetCount)) options:0 action:@selector(updateAddPhotoButtonTitle)];
}

- (void)updateAddPhotoButtonTitle
{
    [self.mainVC updateAddPhotoButtonTitle];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientationDidChange:(NSNotification *)notification
{
    [self reloadData];
}

- (void)reloadData
{
    [self layoutPhotos];
    [self updateAddPhotoButtonTitle];
}

#pragma mark - Random photos
- (void)layoutPhotos
{
    // TODO: layoutPhotos
}

#pragma mark - Data controller delegate
- (void)controllerDidChangeContent:(KLDataController *)controller
{
    [self reloadData];
}

- (void)controller:(KLDataController *)controller didChangeAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths forChangeType:(KLDataChangeType)type
{
    [self reloadData];
}

#pragma mark - KLImagePickerController delegate
- (void)imagePickerController:(KLImagePickerController *)picker didFinishPickingImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.dataController addPhotos:assets completion:nil];
}

#pragma mark - KLCameraViewController delegate
- (void)cameraViewController:(KLCameraViewController *)cameraVC didFinishSaveImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.dataController addPhotos:assets completion:nil];
}

@end
