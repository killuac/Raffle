//
//  AppDelegate+Analytics.m
//  Raffle
//
//  Created by Killua Liu on 1/19/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "AppDelegate+Analytics.h"
@import Aspects;
@import Fabric;
@import Crashlytics;

NSString *const KLLogPageViewName = @"KLLogPageViewName";
NSString *const KLLogTrackedEvents = @"KLLogTrackedEvents";
NSString *const KLLogEventName = @"KLLogEventName";
NSString *const KLLogEventSelectorName = @"KLLogEventSelectorName";
NSString *const KLLogEventHandlerBlock = @"KLLogEventHandlerBlock";
NSString *const KLIsNeedPlaySound = @"KLIsNeedPlaySound";

typedef void (^KLAspectHandlerBlock)(id<AspectInfo> aspectInfo);


@interface AppDelegate ()

@property (nonatomic, strong) NSMutableDictionary *configs;

@end

@implementation AppDelegate (Analytics)

- (void)setupAppAnalytics
{
    [Fabric with:@[[Crashlytics class]]];
    [self prepareForAnalytics];
}

- (void)setConfigs:(NSDictionary *)configs
{
    objc_setAssociatedObject(self, @selector(configs), configs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)configs
{
    return objc_getAssociatedObject(self, @selector(configs));
}

- (void)prepareForAnalytics
{
    self.configs = [NSMutableDictionary dictionaryWithContentsOfURL:KLURLPlistFile(@"Analytics")];
    
//  Hook view controllers
//    [UIViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
//        if ([self isNeedLoggingForAspectInfo:aspectInfo]) {
//            KLDispatchGlobalAsync(^{
//                [MobClick beginLogPageView:[self pageViewNameForAspectInfo:aspectInfo]];
//            });
//        }
//    } error:NULL];
//    
//    [UIViewController aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
//        if ([self isNeedLoggingForAspectInfo:aspectInfo]) {
//            KLDispatchGlobalAsync(^{
//                [MobClick endLogPageView:[self pageViewNameForAspectInfo:aspectInfo]];
//            });
//        }
//    } error:NULL];
    
//  Hook events
    [self.configs.allKeys enumerateObjectsUsingBlock:^(NSString *className, NSUInteger idx, BOOL *stop) {
        Class clazz = NSClassFromString(className);
        NSDictionary *config = self.configs[className];
        
        [config[KLLogTrackedEvents] enumerateObjectsUsingBlock:^(NSDictionary *event, NSUInteger idx, BOOL *stop) {
            SEL selector = NSSelectorFromString(event[KLLogEventSelectorName]);
            KLAspectHandlerBlock block = event[KLLogEventHandlerBlock];
            NSString *eventName = event[KLLogEventName];
            
            [clazz aspect_hookSelector:selector withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
                CLS_LOG(@"%@", eventName);          // Fabric Crashlytics
                
                KLDispatchGlobalAsync(^{
                    if (block) block(aspectInfo);
                    [Answers logCustomEventWithName:eventName customAttributes:nil];
                });
            } error:NULL];
        }];
    }];
}

// NOTE: aspectInfo.instance is not thread safe, so only call this method in main thread.
- (NSString *)pageViewNameForAspectInfo:(id<AspectInfo>)aspectInfo
{
    NSString *className = NSStringFromClass([aspectInfo.instance class]);
    NSString *pageViewName = self.configs[className][KLLogPageViewName];
    
    if (pageViewName && ![className isEqualToString:pageViewName]) {
        KLLog(@"Analytics Warning: Page view name(%@) should be same with class name(%@)", pageViewName, className);
    }
    
    return (pageViewName ? pageViewName : className);
}

- (BOOL)isNeedLoggingForAspectInfo:(id<AspectInfo>)aspectInfo
{
    return ([NSStringFromClass([aspectInfo.instance class]) hasPrefix:@"KL"]);
}

@end
