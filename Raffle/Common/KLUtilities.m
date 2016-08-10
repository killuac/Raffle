//
//  KLUtilities.m
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLUtilities.h"

#pragma mark - File path helper method
NSURL *FetchOrCreateFileURL(NSString *path)
{
    NSString *lastPathComponent = @"";
    if (path.pathExtension.length) {
        lastPathComponent = path.lastPathComponent;
        path = [path stringByDeletingLastPathComponent];
    }
    NSURL *pathURL = [NSURL URLWithString:path];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:pathURL
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:nil];
    }
    
    return (lastPathComponent.length ? [pathURL URLByAppendingPathComponent:lastPathComponent] : pathURL);
}

NSURL *KLDocumentFileURL(NSString *fileName)
{
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [docDir stringByAppendingPathComponent:fileName];
    return FetchOrCreateFileURL(path);
}

NSURL *KLCacheFileURL(NSString *fileName)
{
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [docDir stringByAppendingPathComponent:fileName];
    return FetchOrCreateFileURL(path);
}

NSURL *KLTemporaryFileURL(NSString *fileName)
{
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *path = [tmpDir stringByAppendingPathComponent:fileName];
    return FetchOrCreateFileURL(path);
}

NSURL *KLApplicationSupportFileURL(NSString *fileName)
{
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [docDir stringByAppendingPathComponent:fileName];
    return FetchOrCreateFileURL(path);
}

NSURL *KLPlistFileURL(NSString *fileName)
{
    return [[NSBundle mainBundle] URLForResource:fileName withExtension:@"plist"];
}

#pragma mark - Runtime helper method
NSArray* KLClassGetSubClasses(Class superClass)
{
    NSMutableArray *classArray = [NSMutableArray array];
    
    int classCount = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    classes = (__unsafe_unretained Class*) malloc(sizeof(Class) * classCount);
    classCount = objc_getClassList(classes, classCount);
    
    for (int i = 0; i < classCount; i++) {
        Class class = classes[i];
        do{
            class = class_getSuperclass(class);
        } while(class && class != superClass);
        
        if (!class) continue;
        
        [classArray addObject:classes[i]];
    }
    free(classes);
    
    return classArray;
}

void KLSwizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector, BOOL isClassMethod)
{
    // the method might not exist in the class, but in its superclass
    Method originalMethod = isClassMethod ? class_getClassMethod(class, originalSelector) : class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = isClassMethod ? class_getClassMethod(class, swizzledSelector) : class_getInstanceMethod(class, swizzledSelector);
    
    // class_addMethod will fail if original method already exists
    Class cls = isClassMethod ? object_getClass(class) : class;
    BOOL isAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    // the method doesn’t exist and we just added one
    if (isAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
