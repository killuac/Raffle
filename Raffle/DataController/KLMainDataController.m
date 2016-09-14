//
//  KLMainDataController.m
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLMainDataController.h"
#import "KLDrawPoolModel.h"

@interface KLMainDataController ()

@property (nonatomic, strong) NSArray <KLDrawPoolModel *> *drawPools;

@end

@implementation KLMainDataController

- (instancetype)init
{
    if (self = [super init]) {
        _drawPools = [KLDrawPoolModel MR_findAllInContext:[NSManagedObjectContext MR_rootSavingContext]];
        if (self.pageCount == 0) {
            _drawPools = @[[KLDrawPoolModel MR_createEntityInContext:[NSManagedObjectContext MR_rootSavingContext]]];
        }
    }
    return self;
}

- (NSUInteger)pageCount
{
    return self.drawPools.count;
}

- (KLDrawPoolDataController *)drawPoolDataControllerAtIndex:(NSUInteger)index
{
    KLDrawPoolDataController *dataController = [KLDrawPoolDataController dataControllerWithModel:self.drawPools[index]];
    dataController.pageIndex = index;
    return dataController;
}

@end
