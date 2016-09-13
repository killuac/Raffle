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

@end
