//
//  UIDevice+Base.h
//  Raffle
//
//  Created by Killua Liu on 11/14/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Base)

@property (nonatomic, copy, readonly) NSString *MACAddress;
@property (nonatomic, copy, readonly) NSString *uniqueDeviceIdentifier;
@property (nonatomic, copy, readonly) NSString *uniqueAdvertisingIdentifier;

@end
