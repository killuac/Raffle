//
//  KLMainViewModel.h
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLDrawPoolViewModel.h"

@interface KLMainViewModel : NSObject

@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, assign, readonly) NSUInteger drawPoolCount;
@property (nonatomic, assign, readonly) BOOL isPageScrollEnabled;

- (KLDrawPoolViewModel *)drawPoolViewModelAtIndex:(NSUInteger)index;

@end
