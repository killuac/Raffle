//
//  KLSegmentControl.h
//  Raffle
//
//  Created by Killua Liu on 7/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KLSegmentControl;
@protocol KLSegmentControlDelegate <NSObject>

- (void)segmentControl:(KLSegmentControl *)segmentControl didSelectSegmentAtIndex:(NSUInteger)index;

@end


@interface KLSegmentControl : UIView

+ (instancetype)segmentControlWithItems:(NSArray *)items;   // items can be NSStrings

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, weak) id <KLSegmentControlDelegate> delegate;

- (void)reloadData;

- (void)selectSegmentAtIndex:(NSUInteger)index;
- (void)scrollWithOffsetRate:(CGFloat)offsetRate;

@end
