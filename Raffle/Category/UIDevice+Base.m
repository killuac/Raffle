//
//  UIDevice+Base.m
//  Raffle
//
//  Created by Killua Liu on 11/14/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "UIDevice+Base.h"
#import "NSString+Base.h"
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <AdSupport/ASIdentifierManager.h>

@implementation UIDevice (Base)

- (NSString *)MACAddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = (char *)malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    
    return outstring;
}

- (NSString *)uniqueDeviceIdentifier
{
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@", UIDevice.currentDevice.MACAddress, NSBundle.mainBundle.bundleIdentifier];
    return stringToHash.MD5String;
}

- (NSString *)uniqueAdvertisingIdentifier
{
    return [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString;
}

@end
