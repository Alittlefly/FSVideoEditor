//
//  NSString+GC.h
//  FlyShow
//
//  Created by 高超的开发 on 14-8-18.
//  Copyright (c) 2014年 牟亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (GC)

/**
 *  系统字体的长度
 *
 *  @param string   自浮窗
 *  @param fontSize 字体大小
 *
 *  @return 长度
 */
+ (CGFloat)WidthFromString:(NSString *)string withFont:(CGFloat)fontSize;
/**
 *  系统字体的长度
 *
 *  @param string   自浮窗
 *  @param fontSize 字体大小
 *
 *  @return 长度
 */

+ (CGFloat)WidthFromString:(NSString *)string withBoldFont:(CGFloat)fontSize;
/**
 *  字符串的高度
 *
 *  @param string   字符串
 *  @param fontSize 系统字体大小
 *  @param width    限制的宽度
 *
 *  @return 高
 */
+ (CGFloat)heightFromString:(NSString *)string withFont:(CGFloat)fontSize WithWidth:(CGFloat)width;
/**
 *  去除字符串中的换行符 并计算宽度
 *
 *  @param string   字符串
 *  @param font     字体
 *  @param fontSize 字体大小
 *
 *  @return w
 */
+ (CGFloat)WidthFromString:(NSString *)string withFont:(UIFont *)font WithFontSize:(CGFloat)fontSize;
/**
 *  去除字符串中的换行符 并计算宽度
 *
 *  @param string   字符串
 *  @param font     字体
 *  @param fontSize 字体大小
 *  @param fontName 字体名称
 *  @return w
 */
+ (CGFloat)heightFromString:(NSString *)string withFont:(CGFloat)fontSize WithWidth:(CGFloat)width withFontName:(NSString*)fontName;
/**
 *  自定义字体
 *
 *  @param string   字符串
 *  @param fontName 字体名称
 *  @param fontSize 字体尺寸
 *
 *  @return 字符串的长度
 */
+ (CGFloat)widthWithString:(NSString *)string withFontName:(NSString *)fontName WithFontSize:(CGFloat )fontSize;
/**
 *  限定宽度计算一段纯文本的高度
 *
 *  @param string       文本
 *  @param fontSize     字体小
 *  @param limitedWidth 限制的最大宽度
 *
 *  @return 文本的高度
 */
+ (CGFloat)heightWithString:(NSString *)string withSystemFontSize:(CGFloat)fontSize WithLimitedWidth:(CGFloat)limitedWidth;
/**
 *  根基字体算长度
 *
 *  @param string   <#string description#>
 *  @param fontSize <#fontSize description#>
 *  @param fontName <#fontName description#>
 *
 *  @return <#return value description#>
 */
+ (CGFloat)WidthFromString:(NSString *)string withFont:(CGFloat)fontSize withFontName:(NSString *)fontName;


+ (CGFloat)HeightFromString:(NSString *)string withFont:(UIFont *)font MaxTextWidth:(CGFloat)maxWidth;
/**
 *  去除空白字符
 *
 *  @param message <#message description#>
 *
 *  @return <#return value description#>
 */
+(NSString*)dealWithMessage:(NSString*)message;

// jixing
+ (NSString*)deviceString;

/**
 *  UTF 8
 *
 *  @param aUnicodeString <#aUnicodeString description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)replaceUnicode:(NSString*)aUnicodeString;

/**
 *  UTF 8
 *
 *  @param money <#aUnicodeString description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)countNumAndChangeformat:(NSString *)num;


- (CGFloat)widthForFont:(UIFont *)font;
@end
