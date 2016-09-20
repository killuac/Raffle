//
//  KLMainDataController.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLMainDataController.h"
#import "KLDrawBoxModel.h"

@interface KLMainDataController ()

@property (nonatomic, strong) NSArray <KLDrawBoxModel *> *drawBoxes;

@end

@implementation KLMainDataController

- (instancetype)init
{
    if (self = [super init]) {
        _drawBoxes = [KLDrawBoxModel MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]];
        if (self.pageCount == 0) {
            _drawBoxes = @[[KLDrawBoxModel MR_createEntityInContext:[NSManagedObjectContext MR_rootSavingContext]]];
        }
    }
    return self;
}

- (NSUInteger)pageCount
{
    return self.drawBoxes.count;
}

- (KLDrawBoxDataController *)drawBoxDataControllerAtIndex:(NSUInteger)index
{
    KLDrawBoxDataController *dataController = [KLDrawBoxDataController dataControllerWithModel:self.drawBoxes[index]];
    dataController.pageIndex = index;
    return dataController;
}

@end
