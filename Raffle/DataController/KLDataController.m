//
//  KLDataController.m
//  Raffle
//
//  Created by Killua Liu on 9/12/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDataController.h"

@implementation KLDataController

#pragma mark - Lifecycle
+ (instancetype)dataController
{
    return [[self alloc] init];
}

+ (instancetype)dataControllerWithModel:(id)model
{
    return [[self alloc] initWithModel:model];
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (instancetype)initWithModel:(id)model
{
    return [self init];    // Must overwrite by subclass
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    if (_managedObjectContext) [self saveContext];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Properties
- (NSUInteger)currentPageIndex
{
    if (_currentPageIndex == NSUIntegerMax) {
        _currentPageIndex = 0;
    } else if (_currentPageIndex >= self.pageCount) {
        _currentPageIndex = self.pageCount - 1;
    }
    return _currentPageIndex;
}

- (BOOL)isPageScrollEnabled
{
    return self.pageCount > 0;
}

#pragma mark - Core Data stack
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) return _managedObjectModel;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:APP_BUNDLE_NAME withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) return _persistentStoreCoordinator;
    
    NSError *error = nil;
    NSURL *storeURL = KLURLDocumentFile([APP_BUNDLE_NAME stringByAppendingPathExtension:@"sqlite"]);
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        KLLog(@"Unresolved error %@, %@", error.localizedDescription, error.userInfo);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) return _managedObjectContext;
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support
- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext) return;
    
    NSError *error = nil;
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error.localizedDescription, error.userInfo);
        abort();
    }
}

@end
