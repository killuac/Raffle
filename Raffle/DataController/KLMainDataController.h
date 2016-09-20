//
//  KLMainDataController.h
//  Raffle
//
//  Created by Killua Liu on 7/31/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLDataController.h"
#import "KLDrawBoxDataController.h"

@interface KLMainDataController : KLDataController

- (KLDrawBoxDataController *)drawBoxDataControllerAtIndex:(NSUInteger)index;

@end
