//
//  KLUtilities.h
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UUID_STRING             [UIDevice currentDevice].identifierForVendor.UUIDString
#define IS_IOS_VERSION_9        (TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0)

#define APP_VERSION             [NSBundle mainBundle].localizedInfoDictionary[@"CFBundleShortVersionString"]
#define APP_BUNDLE_NAME         [NSBundle mainBundle].localizedInfoDictionary[@"CFBundleName"]
#define APP_DISPLAY_NAME        [NSBundle mainBundle].localizedInfoDictionary[@"CFBundleDisplayName"]
#define APP_COPYRIGHT           [NSBundle mainBundle].localizedInfoDictionary[@"NSHumanReadableCopyright"]

#define SCREEN_SCALE            [UIScreen mainScreen].scale
#define SCREEN_BOUNDS           [UIScreen mainScreen].bounds
#define SCREEN_SIZE             SCREEN_BOUNDS.size
#define SCREEN_WIDTH            SCREEN_SIZE.width
#define SCREEN_HEIGHT           SCREEN_SIZE.height
#define SCREEN_CENTER           CGPointMake(CGRectGetMidX(SCREEN_BOUNDS), CGRectGetMidY(SCREEN_BOUNDS))
#define RESOLUTION_SIZE         [UIScreen mainScreen].preferredMode.size

#define TVC_REUSE_IDENTIFIER    @"TableViewCellReuseIdentifier"
#define CVC_REUSE_IDENTIFIER    @"CollectionViewCellReuseIdentifier"
#define DECLARE_WEAK_SELF       __weak typeof(self) welf = self


typedef void (^KLVoidBlockType)(void);

NS_INLINE UIColor *KLColorWithRGB(CGFloat r, CGFloat g, CGFloat b) { return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]; }
NS_INLINE UIColor *KLColorWithRGBA(CGFloat r, CGFloat g, CGFloat b, CGFloat a) { return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]; }
NS_INLINE UIColor *KLColorWithHexString(NSString *hexString) {
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hexInt; [scanner scanHexInt: &hexInt];
    return KLColorWithRGB((hexInt & 0xFF0000) >> 16, (hexInt & 0xFF00) >> 8, (hexInt & 0xFF));
}

NS_INLINE CGFloat KLPointDistance(CGPoint p1, CGPoint p2) { return sqrtf(powf(p2.x-p1.x, 2) + powf(p2.y-p1.y, 2)); }
NS_INLINE CGFloat KLRadianFromDegree(CGFloat degree) { return (degree * M_PI / 180.0); }


NS_INLINE void KLDispatchMainAsync(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}
NS_INLINE void KLDispatchGlobalAsync(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}
NS_INLINE void KLDispatchMainAfter(NSTimeInterval delay, dispatch_block_t block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}
NS_INLINE void KLDispatchGroupGlobalAsync(dispatch_group_t group, dispatch_block_t block) {
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}
NS_INLINE void KLDispatchGroupMainNotify(dispatch_group_t group, dispatch_block_t block) {
    dispatch_group_notify(group, dispatch_get_main_queue(), block);
}


FOUNDATION_EXPORT NSURL *KLDocumentFileURL(NSString *fileName);
FOUNDATION_EXPORT NSURL *KLCacheFileURL(NSString *fileName);
FOUNDATION_EXPORT NSURL *KLTemporaryFileURL(NSString *fileName);
FOUNDATION_EXPORT NSURL *KLApplicationSupportFileURL(NSString *fileName);
FOUNDATION_EXPORT NSURL *KLPlistFileURL(NSString *fileName);

FOUNDATION_EXPORT NSArray *KLClassGetSubClasses(Class superClass);
FOUNDATION_EXPORT void KLSwizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector, BOOL isClassMethod);
