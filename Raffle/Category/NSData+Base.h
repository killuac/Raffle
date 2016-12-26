//
//  NSData+Base.h
//  Raffle
//
//  Created by Killua Liu on 1/22/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base)

@property (nonatomic, copy, readonly) NSString *MD5String;
@property (nonatomic, copy, readonly) NSString *SHA1String;

@end
