//
//  KLDrawBoxViewController.m
//  Raffle
//
//  Created by Killua Liu on 7/30/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDrawBoxViewController.h"
#import "KLMainViewController.h"

@interface KLDrawBoxViewController () <KLDataControllerDelegate>

@property (nonatomic, strong) KLMainViewController *mainVC;
@property (nonatomic, strong) KLMainDataController *mainDC;

@end

@implementation KLDrawBoxViewController

#pragma mark - Life cycle
+ (instancetype)viewControllerWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex
{
    return [[self alloc] initWithDataController:dataController atPageIndex:pageIndex];
}

- (instancetype)initWithDataController:(KLMainDataController *)dataController atPageIndex:(NSUInteger)pageIndex
{
    if (self = [super init]) {
        _mainDC = dataController;
        _drawBoxDC = [dataController drawBoxDataControllerAtIndex:pageIndex];
        _drawBoxDC.delegate = self;
    }
    return self;
}

- (NSUInteger)pageIndex
{
    return self.drawBoxDC.pageIndex;
}

- (KLMainViewController *)mainVC
{
    return (id)self.parentViewController.parentViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self layoutPhotos];
    [self addObservers];
}

#pragma mark - Observers
- (void)addObservers
{
    self.KVOController = [FBKVOController controllerWithObserver:self];
    [self.KVOController observe:self.drawBoxDC keyPath:@"allAssets" options:0 action:@selector(reloadData)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc
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
}

#pragma mark - Random photos
- (void)layoutPhotos
{
    // TODO: layoutPhotos
}

- (void)randomAnPhoto:(KLAssetBlockType)resultHandler
{
    [[self.drawBoxDC randomAnAsset] originalImageProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        // TODO: Progress
    } resultHandler:resultHandler];
}

#pragma mark - Data controller delegate
- (void)controller:(KLDataController *)controller didChangeAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths forChangeType:(KLDataChangeType)type
{
    switch (type) {
        case KLDataChangeTypeInsert:
            
            break;
            
        case KLDataChangeTypeDelete:
            
            break;
            
        default:
            break;
    }
    
    [self.mainVC becomeFirstResponder];
}

#pragma mark - KLImagePickerController delegate
- (void)imagePickerController:(KLImagePickerController *)picker didFinishPickingImageAssets:(NSArray<PHAsset *> *)assets
{
    [self.drawBoxDC addPhotos:assets];
}

@end
