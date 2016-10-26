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

@property (nonatomic, strong, readonly) KLDrawBoxDataController *currentDrawBoxDC;
@property (nonatomic, assign, readonly) BOOL isAttendeeMode;
@property (nonatomic, assign, readonly) BOOL isReloadButtonHidden;

- (void)switchDrawMode;
- (void)deleteDrawBoxAtIndexPath:(NSIndexPath *)indexPath;
- (KLDrawBoxDataController *)drawBoxDataControllerAtIndex:(NSUInteger)index;

@end
