//
//  KLUtilities.h
//  Raffle
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_PHONE                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_PAD                  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define UUID_STRING             [UIDevice currentDevice].identifierForVendor.UUIDString
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

#ifdef DEBUG
#define KLLog(format, ...)      NSLog(@"%@:%d: %@", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__, [NSString stringWithFormat:format, ##__VA_ARGS__]);
#else
#define KLLog(format, ...)
#endif


typedef void (^KLVoidBlockType)(void);
typedef void (^KLBOOLBlockType)(BOOL finished);

NS_INLINE BOOL KLSystemVersionGreaterThanOrEqualTo(NSInteger version) {
    return [NSProcessInfo processInfo].operatingSystemVersion.majorVersion > version;
}
NS_INLINE CGFloat KLPointDistance(CGPoint p1, CGPoint p2) { return sqrtf(powf(p2.x-p1.x, 2) + powf(p2.y-p1.y, 2)); }
NS_INLINE CGFloat KLRadianFromDegree(CGFloat degree) { return (degree * M_PI / 180.0); }


NS_INLINE void KLDispatchOnce(dispatch_block_t block) {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, block);
}
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


FOUNDATION_EXPORT NSURL *KLURLDocumentFile(NSString *fileName);
FOUNDATION_EXPORT NSURL *KLURLCacheFile(NSString *fileName);
FOUNDATION_EXPORT NSURL *KLURLTemporaryFile(NSString *fileName);
FOUNDATION_EXPORT NSURL *KLURLApplicationSupportFile(NSString *fileName);
FOUNDATION_EXPORT NSURL *KLURLPlistFile(NSString *fileName);

FOUNDATION_EXPORT NSArray *KLClassGetSubClasses(Class superClass);
FOUNDATION_EXPORT void KLClassSwizzleMethod(Class clazz, SEL originalSelector, SEL swizzledSelector, BOOL isClassMethod);
