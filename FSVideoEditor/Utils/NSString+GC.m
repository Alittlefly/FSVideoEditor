//
//  NSString+GC.m
//  FlyShow
//
//  Created by 高超的开发 on 14-8-18.
//  Copyright (c) 2014年 牟亚军. All rights reserved.
//

#import "NSString+GC.h"
#import "sys/utsname.h"
#import "SharedLanguages.h"

@implementation NSString (GC)

+ (NSString *)countNumAndChangeformat:(NSString *)num
{
    int count = 0;
    long long int a = num.longLongValue;
    while (a != 0)
    {
        count++;
        a /= 10;
    }
    NSMutableString *string = [NSMutableString stringWithString:num];
    NSMutableString *newstring = [NSMutableString string];
    while (count > 3) {
        count -= 3;
        NSRange rang = NSMakeRange(string.length - 3, 3);
        NSString *str = [string substringWithRange:rang];
        [newstring insertString:str atIndex:0];
        [newstring insertString:@"," atIndex:0];
        [string deleteCharactersInRange:rang];
    }
    [newstring insertString:string atIndex:0];
    return newstring;
}

+ (CGFloat)WidthFromString:(NSString *)string withFont:(UIFont *)font WithFontSize:(CGFloat)fontSize
{
    // 处理字符串
    NSArray *ContentArray = [string componentsSeparatedByString:@"\r"];
    NSString *newStrings = nil;
    if (ContentArray.count) {
        for(NSString *contentStr in ContentArray)
        {
            newStrings = [newStrings stringByAppendingString:contentStr];
        }
    }
    
//    NSLog(@"newStrings  %@",newStrings);
    
    
     NSString *newString = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // new code
    NSDictionary *dict = @{NSFontAttributeName:font};
    CGRect newSize = [newString boundingRectWithSize:CGSizeMake(MAXFLOAT, fontSize) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:dict context:nil];
    //CGSize Size = [newString sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, fontSize)];
    if(newSize.size.width == 0)
    {
        NSLog(@"%@",string);
    }
    return newSize.size.width;
}
+ (CGFloat)WidthFromString:(NSString *)string withFont:(CGFloat)fontSize
{
    // new code
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGRect newSize = [string boundingRectWithSize:CGSizeMake(0, 10000) options:(NSStringDrawingUsesFontLeading) attributes:dict context:nil];
//    CGSize Size = [string sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(MAXFLOAT, fontSize)];
    return newSize.size.width;
}

+ (CGFloat)WidthFromString:(NSString *)string withBoldFont:(CGFloat)fontSize
{
    // new code
    NSDictionary *dict = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize]};
    CGRect newSize = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, fontSize) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:dict context:nil];
    //    CGSize Size = [string sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(MAXFLOAT, fontSize)];
    return newSize.size.width;
}

+ (CGFloat)WidthFromString:(NSString *)string withFont:(CGFloat)fontSize withFontName:(NSString *)fontName
{
    // new code
    NSDictionary *dict = @{NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]};
    CGRect newSize = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, fontSize) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:dict context:nil];
    //    CGSize Size = [string sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(MAXFLOAT, fontSize)];
    return newSize.size.width;
}
+ (CGFloat)heightFromString:(NSString *)string withFont:(CGFloat)fontSize WithWidth:(CGFloat)width
{
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrapStyle setBaseWritingDirection:IsArabic?NSWritingDirectionRightToLeft:NSWritingDirectionLeftToRight];
    [paragrapStyle setLineBreakMode:NSLineBreakByWordWrapping];
//    [paragrapStyle setParagraphSpacing:1.0f];
//    [paragrapStyle setHeadIndent:2.0f];
//    [paragrapStyle setTailIndent:1.0f];
    
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSParagraphStyleAttributeName:paragrapStyle};
    CGRect SizeRect = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:dict context:nil];
//    CGSize Size = [string sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, MAXFLOAT)];
    return SizeRect.size.height;
}

+ (CGFloat)heightFromString:(NSString *)string withFont:(CGFloat)fontSize WithWidth:(CGFloat)width withFontName:(NSString*)fontName
{
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrapStyle setBaseWritingDirection:IsArabic?NSWritingDirectionRightToLeft:NSWritingDirectionLeftToRight];
    [paragrapStyle setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *dict = @{NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize],NSParagraphStyleAttributeName:paragrapStyle};
    CGRect SizeRect = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:dict context:nil];
    //    CGSize Size = [string sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, MAXFLOAT)];
    return SizeRect.size.height;
}


+ (CGFloat)widthWithString:(NSString *)string withFontName:(NSString *)fontName WithFontSize:(CGFloat )fontSize
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT,MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} context:nil];
    ;
    return rect.size.width;
}
+ (CGFloat)heightWithString:(NSString *)string withSystemFontSize:(CGFloat)fontSize WithLimitedWidth:(CGFloat)limitedWidth
{
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrapStyle setBaseWritingDirection:NSWritingDirectionNatural];
    [paragrapStyle setLineBreakMode:NSLineBreakByWordWrapping];
//    [paragrapStyle setParagraphSpacing:1.0f];
//    [paragrapStyle setHeadIndent:2.0f];
//    [paragrapStyle setTailIndent:1.0f];
    CGRect contentRect = [string boundingRectWithSize:CGSizeMake(limitedWidth, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSParagraphStyleAttributeName:paragrapStyle} context:nil];
    return CGRectGetHeight(contentRect);
}
+ (CGFloat)HeightFromString:(NSString *)string withFont:(UIFont *)font MaxTextWidth:(CGFloat)maxWidth
{
    CGRect tmpRect = [string boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil] context:nil];

    return ceil(tmpRect.size.height);
}


+(NSString *)replaceUnicode:(NSString *)unicodeStr {
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

+(NSString *)utf8ToUnicode:(NSString *)string
{
    NSUInteger length = [string length];
    unsigned long min = strtoul([@"0x2000" UTF8String],0,16);
    unsigned long max = strtoul([@"0x206F" UTF8String],0,16);
    NSMutableString *s = [NSMutableString stringWithCapacity:0];
    for (int i = 0;i < length; i++)
    {
        unichar _char = [string characterAtIndex:i];
        //判断是否为英文和数字
        if (_char <= '9' && _char >= '0')
        {
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i, 1)]];
        }
        else if(_char >= 'a' && _char <= 'z')
        {
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i, 1)]];
        }
        else if(_char >= 'A' && _char <= 'Z')
        {
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i, 1)]];
        }
        else
        {
            NSString* str = [NSString stringWithFormat:@"%x",[string characterAtIndex:i]];
            unsigned long red = strtoul([str UTF8String],0,16);
            if (red > min && red < max) {
                continue;
            }
            [s appendFormat:@"\\u%x",[string characterAtIndex:i]];
        }
    }
    return s;
}

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

- (CGFloat)widthForFont:(UIFont *)font {
    CGSize size = [self sizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
    return size.width;
}

- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width {
    CGSize size = [self sizeForFont:font size:CGSizeMake(width, HUGE) mode:NSLineBreakByWordWrapping];
    return size.height;
}

//过滤空白字符
+(NSString*)dealWithMessage:(NSString*)message
{
    
    NSString* unicodeStr =[NSString utf8ToUnicode:message];
    
    NSString* newStr = [NSString replaceUnicode:unicodeStr];
    
    return newStr;
}
+ (NSString*)deviceString
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone2G(A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone3G(A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone3GS(A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone4(A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone4(A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone4(A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone4S(A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone5(A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone5(A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone5c(A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone5c(A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone5s(A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone5s(A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone6Plus(A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone6(A1549/A1586)";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone6s(A1700)";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone6sPlus(A1699)";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPodTouch1G(A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPodTouch2G(A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPodTouch3G(A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPodTouch4G(A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPodTouch5G(A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad1G(A1219/A1337)";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad2(A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad2(A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad2(A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad2(A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPadMini1G(A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPadMini1G(A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPadMini1G(A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad3(A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad3(A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad3(A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad4(A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad4(A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad4(A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPadAir(A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPadAir(A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPadAir(A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPadMini2G(A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPadMini2G(A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPadMini2G(A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhoneSimulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhoneSimulator";
//    NSLog(@"NOTE: Unknown device type: %@", platform);
    return platform;
}
/*
 
 - (NSString *)iphoneType {
 
 http://www.jianshu.com/p/02bba9419df8
 
 http://www.jianshu.com/p/0d84e6852c5a
 
 1.手机系统版本：9.1
 
 NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
 
 2.手机类型：iPhone 6
 
 NSString* phoneModel = [self iphoneType];//方法在下面
 
 3.手机系统：iPhone OS
 
 NSString * iponeM = [[UIDevice currentDevice] systemName];
 
 4.电池电量
 
 CGFloat batteryLevel=[[UIDevicecurrentDevice]batteryLevel];
 
 文／天明依旧（简书作者）
 原文链接：http://www.jianshu.com/p/02bba9419df8
 著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。
 
 
 需要导入头文件：#import <sys/utsname.h>
 
 struct utsname systemInfo;
 
 uname(&systemInfo);
 
 NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
 
 if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
 
 if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
 
 if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
 
 if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
 
 if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
 
 if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
 
 if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
 
 if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
 
 if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
 
 if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
 
 if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
 
 if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
 
 if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
 
 if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
 
 if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
 
 if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
 
 if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
 
 if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
 
 if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
 
 if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
 
 if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
 
 if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
 
 if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
 
 if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
 
 if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
 
 if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
 
 if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
 
 if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
 
 if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
 
 if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
 
 if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
 
 if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
 
 if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
 
 if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
 
 if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
 
 if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
 
 if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
 
 if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
 
 if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
 
 if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
 
 if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
 
 if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
 
 if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
 
 if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
 
 if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
 
 if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
 
 if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
 
 return platform;
 
 }
 
 文／天明依旧（简书作者）
 原文链接：http://www.jianshu.com/p/02bba9419df8
 著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。
 
 */
@end
