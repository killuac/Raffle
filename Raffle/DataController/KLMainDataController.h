//
//  KLMainDataController.h
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDataController.h"
#import "KLDrawPoolDataController.h"

@interface KLMainDataController : KLDataController

- (KLDrawPoolDataController *)drawPoolDataControllerAtIndex:(NSUInteger)index;

@end
