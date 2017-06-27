//
//  NSString+Time.h
//  FlyShow
//
//  Created by gaochao on 15/3/12.
//  Copyright (c) 2015年 高超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Time)
+ (NSString *)NowTimeWithHourAndMinute;
+ (NSString *)covertTimeToloaclTime:(long long)startTime;
+ (NSString *)covertTimeToTwelveTime:(long long)startTime;
+ (BOOL)currentDateIsToday:(long long)startTime;
+ (BOOL)currentDateIsTomorrow:(long long)startTime;
+ (NSString *)GetCurrentDate;

+(NSString *)covertTimeAllFormat:(long long)time;
/**
 *  返回当日时间  不是当日时间返回nil
 *
 *  @param startTime 时间戳 毫秒数
 *
 *  @return 格式化之后的字付串
 */
+ (NSString *)todayTimeStr:(long long)startTime;
/**
 *  返回年月日格式的时间字符串
 *
 *  @param startTime 时间long 秒数
 *
 *  @return <#return value description#>
 */
+(NSString *)timeformatYYMMDD:(long long)startTime;

/**
 *  返回月日格式的时间字符串
 *
 *  @param startTime <#startTime description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)timeformatMMDD:(long long)startTime;
/**
 *  返回年月格式的时间字符串
 *
 *  @param startTime <#startTime description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)timeformatYYYYMM:(long long)startTime;
/**
 *  根据语言返回年月日格式的时间字符串
 *
 *  @param startTime 时间long 秒数
 *
 *  @return <#return value description#>
 */
+(NSString *)timeformatYYMMDDIgnoreLanguage:(long long)startTime;
+(NSString *)timeformatMMDDIgnoreLanguage:(long long)startTime;
/**
 *  返回时分格式的时间字符串
 *
 *  @param startTime <#startTime description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)timeformatHHMM:(long long)startTime;
/**
 *  更新显示时间
 *
 *  @param endTime     结束时间
 *  @param currentTime 开始时间
 *
 *  @return 返回 天  小时  分钟 秒 
 */
+(NSString *)updateTimeLabel:(long long)endTime currentTime:(long long)currentTime;

/**
 *  更新显示时间
 *
 *  @param endTime     结束时间
 *  @param currentTime 开始时间
 *
 *  @return 返回 天  小时  分钟 秒
 */
+(NSString *)updateTimeLabelWithTimeString:(long long)endTime currentTime:(long long)currentTime;
/**
 *  返回连字符 － 连接的6个月前的时间
 *
 *  @return
 */
+(NSString*)GetLastSixMonthData;
/**
 *   返回连字符 － 连接的当前前的时间
 *
 *  @return
 */
+(NSString *)GetCurrentDate_;

/**
 *  月 日 年
 *
 *  @param startTime
 *
 *  @return
 */
+(NSString *)timeformatMMDDYY:(long long)startTime;

+ (NSString *)intervalSinceNow: (long long)passTime;
+ (NSString *)intervalSinceNowValueVip: (long long)passTime  SVip:(long long)spassTime;

+(NSString *)todayTimeString;
+(NSString *)todayTimeStringFormatDDMMYY;
+(NSString *)timeformatMMDDYYStyle2:(long long)startTime;


+(NSString *)englishTimeWithTime:(long long)time showToday:(BOOL)showToday;
+(NSString *)lastTimeWithOutZeroStart:(long long)lastTime;
+(NSString *)lastTimeWithOutZeroStartWithUnit:(long long)lastTime;
@end
