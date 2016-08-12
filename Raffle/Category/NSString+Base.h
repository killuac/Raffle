//
//  NSString+Base.h
//  Raffle
//
//  Created by Killua Liu on 12/16/15.
//  Copyright (c) 2015 Syzygy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE BOOL KLStringIsEmpty(NSString *string) { return ([string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0); }

@interface NSString (Base)

@property (nonatomic, copy, readonly) NSString *MD5String;
@property (nonatomic, copy, readonly) NSString *SHA1String;

@property (nonatomic, copy, readonly) NSString *base62String;
@property (nonatomic, copy, readonly) NSString *stringFromBase62;

@property (nonatomic, copy, readonly) NSString *quotedString;

@property (nonatomic, assign, readonly) BOOL isValidMobile;
@property (nonatomic, assign, readonly) BOOL isValidEmail;
@property (nonatomic, assign, readonly) BOOL isValidPassword;
@property (nonatomic, assign, readonly) BOOL isValidSMSCode;
@property (nonatomic, assign, readonly) BOOL isNumberCharacter;
@property (nonatomic, assign, readonly) BOOL isEmailCharacter;
@property (nonatomic, assign, readonly) BOOL isNicknameCharacter;
@property (nonatomic, assign, readonly) BOOL containsUnicodeCharacter;

- (NSString *)increment;
- (NSString *)decrement;

- (CGFloat)widthWithFont:(UIFont *)font;
- (CGFloat)heightWithFont:(UIFont *)font;
- (CGSize)sizeWithFont:(UIFont *)font;
- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width;

@end
