//
//  KLDataController.h
//  Raffle
//
//  Created by Killua Liu on 9/12/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KLDataChangeType) {
    KLDataChangeTypeInsert = 1,
    KLDataChangeTypeDelete = 2,
    KLDataChangeTypeMove = 3,
    KLDataChangeTypeUpdate = 4
};

@class KLDataController;
@protocol KLDataControllerDelegate <NSObject>

@optional
- (void)controllerWillChangeContent:(KLDataController *)controller;
- (void)controllerDidChangeContent:(KLDataController *)controller;

- (void)controller:(KLDataController *)controller didChangeAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths forChangeType:(KLDataChangeType)type;
- (void)controller:(KLDataController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(KLDataChangeType)type;
- (void)controller:(KLDataController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(KLDataChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

@end


@protocol KLDataControllerProtocol <NSObject>

@optional
- (instancetype)initWithModel:(id)model;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface KLDataController : NSObject <KLDataControllerProtocol>

+ (instancetype)dataController;
+ (instancetype)dataControllerWithModel:(id)model;

@property (nonatomic, weak) id <KLDataControllerDelegate> delegate;

@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign, getter=isLoadingData) BOOL loadingData;

@property (nonatomic, assign, readonly) NSUInteger pageCount;
@property (nonatomic, assign, readonly) NSUInteger sectionCount;
@property (nonatomic, assign, readonly) NSUInteger itemCount;
@property (nonatomic, assign, readonly) BOOL isPageScrollEnabled;
@property (nonatomic, strong, readonly) NSArray<NSString *> *segmentTitles;

- (void)willChangeContent;
- (void)didChangeContent;
- (void)didChangeAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths forChangeType:(KLDataChangeType)type;
- (void)didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(KLDataChangeType)type;
- (void)didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(KLDataChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

@end
