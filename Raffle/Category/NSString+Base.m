//
//  NSString+Base.m
//  LuckyDraw
//
//  Created by Killua Liu on 12/16/15.
//  Copyright (c) 2015 Syzygy. All rights reserved.
//

#import "NSString+Base.h"
#import <CommonCrypto/CommonDigest.h>
#import <RegExCategories/RegExCategories.h>

#define ALPHABET_62 @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

@implementation NSString (Base)

#pragma mark - Digest
- (NSString *)toMD5String
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data toMD5String];
}

- (NSString *)toSHA1String
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data toSHA1String];
}

//- (NSString *)SHA1String
//{
//    const char *cstr = [self UTF8String];
//    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
//    CC_SHA1(cstr, (CC_LONG)strlen(cstr), digest);
//    
//    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH];
//    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
//        [output appendFormat:@"%02x", digest[i]];
//    }
//    
//    return output;
//}

#pragma mark - Base 62
- (NSString *)encodeNumber:(NSInteger)number withAlphabet:(NSString *)alphabet
{
    NSUInteger base = alphabet.length;
    
    if (number < alphabet.length){
        return [alphabet substringWithRange:NSMakeRange(number, 1)];
    }
    
    return [NSString stringWithFormat:@"%@%@",
            [self encodeNumber:number/base withAlphabet:alphabet],  // eg: 769/10 = 76
            [alphabet substringWithRange:NSMakeRange(number%base, 1)]];
}

- (NSString *)decodeWithAlphabet:(NSString *)alphabet
{
    NSInteger number = 0;
    for (int i = 0; i < self.length; i++) {
        NSRange range = [alphabet rangeOfString:[self substringWithRange:NSMakeRange(i, 1)]];
        number = number * alphabet.length + range.location;
    }
    
    return @(number).stringValue;
}

- (NSString *)toBase62String
{
    return [self encodeNumber:self.integerValue withAlphabet:ALPHABET_62];
}

- (NSString *)fromBase62String
{
    return [self decodeWithAlphabet:ALPHABET_62];
}

- (NSString *)increment
{
    NSInteger number = [self fromBase62String].integerValue + 1;
    return [@(number).stringValue toBase62String];
}

- (NSString *)decrement
{
    NSInteger number = [self fromBase62String].integerValue - 1;
    return [@(number).stringValue toBase62String];
}

#pragma mark - Validation
- (BOOL)isValidMobile
{
    return [self isMatch:RX(@"^1[34578]\\d{9}$")];
}

- (BOOL)isValidEmail
{
    return [self isMatch:RX(@"^(\\w.)+(\\w)*@([\\w-])+(\\.\\w{2,3}){1,3}$")];
}

- (BOOL)isValidPassword
{
    return ![self containsUnicodeCharacter];
}

- (BOOL)isValidSMSCode
{
    return [self isMatch:RX(@"\\d{6}")];
}

- (BOOL)containsUnicodeCharacter
{
    return [self isMatch:RX(@"[\\u4e00-\\u9fa5]")] || [self isMatch:RX(@"[^\\x00-\\xff]")];
}

- (BOOL)isNumberCharacter
{
    return [self isMatch:RX(@"^\\d+$")];
}

- (BOOL)isEmailCharacter
{
    return [self isMatch:RX(@"[\\w.@-]")] && ![self containsUnicodeCharacter];
}

- (BOOL)isNicknameCharacter
{
    return ![self isMatch:RX(@"\\s")];
}

#pragma mark - Size
- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width
{
    return [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                              options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                           attributes:@{ NSFontAttributeName:font }
                              context:nil].size;
}

- (CGSize)sizeWithFont:(UIFont *)font
{
    return [self sizeWithAttributes:@{ NSFontAttributeName:font }];
}

- (CGFloat)widthWithFont:(UIFont *)font
{
    return [self sizeWithFont:font].width;
}

- (CGFloat)heightWithFont:(UIFont *)font
{
    return [self sizeWithFont:font].height;
}

#pragma mark - Localization
- (NSString *)quotedString
{
    NSLocale *locale = [NSLocale currentLocale];
    id bQuote = [locale objectForKey:NSLocaleQuotationBeginDelimiterKey];
    id eQuote = [locale objectForKey:NSLocaleQuotationEndDelimiterKey];
    return [NSString stringWithFormat:@"%@%@%@", bQuote, self, eQuote];
}

@end
