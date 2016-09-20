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

#pragma mark - Deleate method
- (void)willChangeContent
{
    if ([self.delegate respondsToSelector:@selector(controllerWillChangeContent:)]) {
        [self.delegate controllerDidChangeContent:self];
    }
}

- (void)didChangeContent
{
    if ([self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
        [self.delegate controllerDidChangeContent:self];
    }
}

- (void)didChangeAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths forChangeType:(KLDataChangeType)type
{
    if ([self.delegate respondsToSelector:@selector(controller:didChangeAtIndexPaths:forChangeType:)]) {
        [self.delegate controller:self didChangeAtIndexPaths:indexPaths forChangeType:type];
    }
}

- (void)didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(KLDataChangeType)type
{
    if ([self.delegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)]) {
        [self.delegate controller:self didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
    }
}

- (void)didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(KLDataChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if ([self.delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        [self.delegate controller:self didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    }
}

@end
