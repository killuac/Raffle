//
//  KLDataController.h
//  Raffle
//
//  Created by Killua Liu on 9/12/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KLDataController;
@protocol KLDataControllerDelegate <NSObject>

@optional
- (void)controllerWillChangeContent:(KLDataController *)controller;
- (void)controllerDidChangeContent:(KLDataController *)controller;

@end


@interface KLDataController : NSObject

+ (instancetype)dataController;
+ (instancetype)dataControllerWithModel:(id)model;
- (instancetype)initWithModel:(id)model;

@property (nonatomic, weak) id <KLDataControllerDelegate> delegate;

@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, assign, readonly) NSUInteger pageCount;
@property (nonatomic, assign, readonly) NSUInteger sectionCount;
@property (nonatomic, assign, readonly) NSUInteger itemCount;
@property (nonatomic, assign, readonly) BOOL isPageScrollEnabled;
@property (nonatomic, strong, readonly) NSArray<NSString *> *segmentTitles;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
