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

@property (nonatomic, readonly) NSString *MD5String;
@property (nonatomic, readonly) NSString *SHA1String;

@property (nonatomic, readonly) NSString *base62String;
@property (nonatomic, readonly) NSString *stringFromBase62;

@property (nonatomic, readonly) NSString *quotedString;

@property (nonatomic, readonly) BOOL isValidMobile;
@property (nonatomic, readonly) BOOL isValidEmail;
@property (nonatomic, readonly) BOOL isValidPassword;
@property (nonatomic, readonly) BOOL isValidSMSCode;
@property (nonatomic, readonly) BOOL isNumberCharacter;
@property (nonatomic, readonly) BOOL isEmailCharacter;
@property (nonatomic, readonly) BOOL isNicknameCharacter;
@property (nonatomic, readonly) BOOL containsUnicodeCharacter;

- (NSString *)increment;
- (NSString *)decrement;

- (CGFloat)widthWithFont:(UIFont *)font;
- (CGFloat)heightWithFont:(UIFont *)font;
- (CGSize)sizeWithFont:(UIFont *)font;
- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width;

@end
