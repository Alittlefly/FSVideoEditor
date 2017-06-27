//
//  NSString+Time.m
//  FlyShow
//
//  Created by gaochao on 15/3/12.
//  Copyright (c) 2015年 高超. All rights reserved.
//

#import "NSString+Time.h"
//#import "NSDate+Category.h"

@implementation NSString (Time)
+ (NSString *)NowTimeWithHourAndMinute
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    long hour = [dateComponent hour];
    long minute = [dateComponent minute];
    NSString *hourStr;
    if (hour < 10) {
        hourStr = [NSString stringWithFormat:@"0%ld",hour];
    }
    else
    {
        hourStr = [NSString stringWithFormat:@"%ld",hour];
    }
    NSString *minuteStr;
    if (minute < 10) {
        minuteStr = [NSString stringWithFormat:@"0%ld",minute];
    }else
    {
        minuteStr = [NSString stringWithFormat:@"%ld",minute];
        
    }
    NSString *time = [NSString stringWithFormat:@"%@:%@",hourStr,minuteStr];
    
    return time;
}
+ (NSString *)StringWithPaiBanTime:(long long)PaiBanTime
{
    
    return  [NSString covertTimeToTwelveTime:PaiBanTime];
}
//二十四小时制
+ (NSString *)covertTimeToloaclTime:(long long)startTime
{
    // 11-27
    // 09:12
    NSString *returnStr;
    NSString *todayStr;
    NSString *startStr;
    NSDate *currentDay = [NSDate date];
    NSDateFormatter *MMDDFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *HHMMFormat = [[NSDateFormatter alloc] init];
    [MMDDFormat setTimeZone:[NSTimeZone localTimeZone]];
    [HHMMFormat setTimeZone:[NSTimeZone localTimeZone]];
    [MMDDFormat setDateFormat:@"MM/dd"];
    [HHMMFormat setDateFormat:@"HH:mm"]; // 24小时制
    todayStr = [MMDDFormat stringFromDate:currentDay];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startTime/1000.0];
    startStr = [MMDDFormat stringFromDate:startDate];
    if ([startStr isEqualToString:todayStr]) {
        startStr = [HHMMFormat stringFromDate:startDate];
    }else if ([self currentDateIsTomorrow:startTime])
    {
        startStr = [MMDDFormat stringFromDate:startDate];
    }else 
    {
        startStr = nil;
    }
    
    returnStr = startStr;
    return returnStr;
}
//十二小时制
+ (NSString *)covertTimeToTwelveTime:(long long)startTime
{
    // 11-27
    // 09:12
    NSString *returnStr;
    NSString *todayStr;
    NSString *startStr;
    NSDate *currentDay = [NSDate date];
    NSDateFormatter *MMDDFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *HHMMFormat = [[NSDateFormatter alloc] init];
    [MMDDFormat setTimeZone:[NSTimeZone localTimeZone]];
    [HHMMFormat setTimeZone:[NSTimeZone localTimeZone]];
    [MMDDFormat setDateFormat:@"MM/dd"];
    HHMMFormat.locale=[[NSLocale alloc]initWithLocaleIdentifier:NSGregorianCalendar];
//    [HHMMFormat setDateFormat:@"hh:mm a"]; // 12小时制
    
    [HHMMFormat setAMSymbol:@"AM"];
    [HHMMFormat setPMSymbol:@"PM"];
    [HHMMFormat setDateFormat:@"HH:mm aaa"];

    todayStr = [MMDDFormat stringFromDate:currentDay];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:(startTime)/1000.0];
    startStr = [MMDDFormat stringFromDate:startDate];
    if ([startStr isEqualToString:todayStr]) {
        startStr = [HHMMFormat stringFromDate:startDate];
    }else if ([self currentDateIsTomorrow:startTime])
    {
        startStr = [MMDDFormat stringFromDate:startDate];
    }else
    {
        startStr = nil;
    }
    
    returnStr = startStr;
    return returnStr;
}

+ (BOOL)currentDateIsYesterday:(long long)startTime{
    NSDate *current = [NSDate date];
    NSDateFormatter *MMDDFormat = [[NSDateFormatter alloc] init];
    [MMDDFormat setTimeZone:[NSTimeZone localTimeZone]];
    [MMDDFormat setDateFormat:@"MM/dd"];
    // 今日
    NSString *todayStr = [MMDDFormat stringFromDate:current];
    //判断是不是明天 加上24小时的秒数
    long long isTomorrowDate = startTime + 24 * 3600 * 1000;
    NSDate *yesterdayDate = [NSDate dateWithTimeIntervalSince1970:isTomorrowDate/1000.0];
    // 判断今日
    NSString *yesterdayVer = [MMDDFormat stringFromDate:yesterdayDate];
    return [todayStr isEqualToString:yesterdayVer];
}
+ (BOOL)currentDateIsToday:(long long)startTime{
    NSString *todayStr;
    NSString *startStr;
    NSDate *currentDay = [NSDate date];
    NSDateFormatter *MMDDFormat = [[NSDateFormatter alloc] init];
    [MMDDFormat setTimeZone:[NSTimeZone localTimeZone]];
    [MMDDFormat setDateFormat:@"MM/dd"];
    todayStr = [MMDDFormat stringFromDate:currentDay];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startTime/1000.0];
    startStr = [MMDDFormat stringFromDate:startDate];
    if ([startStr isEqualToString:todayStr]) {
        return YES;
    }else
    {
        return NO;
    }
}
+ (NSString *)todayTimeStr:(long long)startTime
{
    NSString *todayStr = nil;
    NSString *startStr = nil;
    NSString *hourStr  = nil;
    NSDate *currentDay = [NSDate date];
    NSDateFormatter *MMDDFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *HHMMFormat = [[NSDateFormatter alloc] init];
    [MMDDFormat setTimeZone:[NSTimeZone localTimeZone]];
    [HHMMFormat setTimeZone:[NSTimeZone localTimeZone]];
    [MMDDFormat setDateFormat:@"MM/dd"];
    [HHMMFormat setDateFormat:@"HH:mm"];
    todayStr = [MMDDFormat stringFromDate:currentDay];
    //NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startTime/1000.0];
    //判断是不是明天 减去24小时的秒数
    NSDate *TodayDate = [NSDate dateWithTimeIntervalSince1970:startTime/1000.0];
    startStr = [MMDDFormat stringFromDate:TodayDate];
    if ([todayStr isEqualToString:startStr]) {
        hourStr = [HHMMFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:startTime/1000.0]];
    }
    return hourStr;
}
+(NSString *)todayTimeString
{
    NSString *todayStr = nil;
    NSDate *currentDay = [NSDate date];
    NSDateFormatter *MMDDFormat = [[NSDateFormatter alloc] init];
    [MMDDFormat setTimeZone:[NSTimeZone localTimeZone]];
    [MMDDFormat setDateFormat:@"MM/dd"];
    todayStr = [MMDDFormat stringFromDate:currentDay];
    //判断是不是明天 减去24小时的秒数
    return todayStr;
}
+(NSString *)todayTimeStringFormatDDMMYY
{
    NSString *todayStr = nil;
    NSDate *currentDay = [NSDate date];
    NSDateFormatter *MMDDFormat = [[NSDateFormatter alloc] init];
    [MMDDFormat setTimeZone:[NSTimeZone localTimeZone]];
    [MMDDFormat setDateFormat:@"yyyy-MM-dd"];
    todayStr = [MMDDFormat stringFromDate:currentDay];
    //判断是不是明天 减去24小时的秒数
    return todayStr;
}
+ (BOOL)currentDateIsTomorrow:(long long)startTime
{
    NSString *todayStr;
    NSString *startStr;
    NSDate *currentDay = [NSDate date];
    NSDateFormatter *MMDDFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *HHMMFormat = [[NSDateFormatter alloc] init];
    [MMDDFormat setTimeZone:[NSTimeZone localTimeZone]];
    [HHMMFormat setTimeZone:[NSTimeZone localTimeZone]];
    [MMDDFormat setDateFormat:@"MM/dd"];
    [HHMMFormat setDateFormat:@"hh:mm"];
    todayStr = [MMDDFormat stringFromDate:currentDay];
    //NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startTime/1000.0];
    //判断是不是明天 减去24小时的秒数
    long long isTomorrowDate = startTime - 24 * 3600 * 1000;
    NSDate *TomorrowDate = [NSDate dateWithTimeIntervalSince1970:isTomorrowDate/1000.0];
    startStr = [MMDDFormat stringFromDate:TomorrowDate];
    // NSLog(@"startStr  %@    todayStr %@",startStr,todayStr);
    if ([startStr isEqualToString:todayStr]) {
        return YES;
    }else
    {
        return NO;
    }
    
}

+ (NSString *)GetCurrentDate
{
    NSString *timeString = @"";
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger year = [dateComponent year];
    NSInteger month = [dateComponent month];
    NSInteger day = [dateComponent day];
    NSInteger hour = [dateComponent hour];
    NSInteger mini = [dateComponent minute];
    NSInteger second = [dateComponent second];
    timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)year]];
    if (month < 10) {
        timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"0%ld",(long)month]];
    }else
    {
        timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)month]];
    }
    
    if (day < 10) {
        timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"0%ld",(long)day]];
    }else
    {
        timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)day]];
    }
    
    timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)hour]];
    timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)mini]];
    timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)second]];
    NSLog(@"[timeString %@]",timeString);
    return timeString;
}
+(NSString *)covertTimeAllFormat:(long long)time
{
    NSString *formatDate = nil;
    NSDateFormatter *AllFormater = [[NSDateFormatter alloc] init];
    [AllFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [AllFormater setLocale:[NSLocale localeWithLocaleIdentifier:NSGregorianCalendar]];
    [AllFormater setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:time/1000.0];
    formatDate = [AllFormater stringFromDate:curDate];
    return formatDate;
}
+(NSString *)timeformatYYMMDD:(long long)startTime
{
    NSString *formatDate = nil;
    NSDateFormatter *AllFormater = [[NSDateFormatter alloc] init];

    [AllFormater setDateFormat:@"dd-MM-yyyy"];

    [AllFormater setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSince1970:startTime];
    formatDate = [AllFormater stringFromDate:curDate];
    return formatDate;
}

+(NSString *)timeformatMMDDYY:(long long)startTime
{
    NSString *formatDate = nil;
    NSDateFormatter *AllFormater = [[NSDateFormatter alloc] init];
    
    [AllFormater setDateFormat:@"MM-dd-yyyy"];
    
    [AllFormater setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSince1970:startTime];
    formatDate = [AllFormater stringFromDate:curDate];
    return formatDate;
}

+(NSString *)timeformatMMDDYYStyle2:(long long)startTime
{
    NSString *formatDate = nil;
    NSDateFormatter *AllFormater = [[NSDateFormatter alloc] init];
    
    [AllFormater setDateFormat:@"dd/MM/yyyy"];
    
    [AllFormater setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSince1970:startTime];
    formatDate = [AllFormater stringFromDate:curDate];
    return formatDate;
}

+(NSString *)timeformatMMDD:(long long)startTime
{
    NSString *formatDate = nil;
    NSDateFormatter *AllFormater = [[NSDateFormatter alloc] init];
    
    [AllFormater setDateFormat:@"MM-dd"];
    
    [AllFormater setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSince1970:startTime];
    formatDate = [AllFormater stringFromDate:curDate];
    return formatDate;
}

+(NSString *)timeformatYYYYMM:(long long)startTime
{
    NSString *formatDate = nil;
    NSDateFormatter *AllFormater = [[NSDateFormatter alloc] init];
    
    [AllFormater setDateFormat:@"yyyy-MM"];
    
    [AllFormater setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSince1970:startTime];
    formatDate = [AllFormater stringFromDate:curDate];
    return formatDate;
}

+(NSString *)timeformatHHMM:(long long)startTime
{
    NSString *formatDate = nil;
    NSDateFormatter *AllFormater = [[NSDateFormatter alloc] init];
    
    [AllFormater setDateFormat:@"HH:mm"];
    
    [AllFormater setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSince1970:startTime];
    formatDate = [AllFormater stringFromDate:curDate];
    return formatDate;
}

+(NSString *)timeformatYYMMDDIgnoreLanguage:(long long)startTime
{
    NSString *formatDate = nil;
    NSDateFormatter *AllFormater = [[NSDateFormatter alloc] init];
    
//    if (IsArabic) {
//        [AllFormater setDateFormat:@"yyyy-MM-dd"];
//    }else{
        [AllFormater setDateFormat:@"dd-MM-yyyy"];
 //   }
    
    [AllFormater setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSince1970:startTime];
    formatDate = [AllFormater stringFromDate:curDate];
    return formatDate;
}

+(NSString *)timeformatMMDDIgnoreLanguage:(long long)startTime
{
    NSString *formatDate = nil;
    NSDateFormatter *AllFormater = [[NSDateFormatter alloc] init];
    
//    if (IsArabic) {
//        [AllFormater setDateFormat:@"dd/MM"];
//    }else{
//        [AllFormater setDateFormat:@"MM/dd"];
//   }
    [AllFormater setDateFormat:@"MM/dd"];
    
    [AllFormater setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSince1970:startTime];
    formatDate = [AllFormater stringFromDate:curDate];
    return formatDate;
}

+(NSString *)updateTimeLabel:(long long)endTime currentTime:(long long)currentTime;
{
    NSString *timeText = @"";
    long long latime = endTime - currentTime;
    NSInteger day = latime/(60 * 24 * 60);
    if (day <= 0) {
        NSInteger hour = latime/(60 * 60);
        if (hour <= 0) {
            NSInteger mins = latime /60;
            if (mins <= 0) {
                NSInteger secd = latime;
                if (secd <= 0) {
                    timeText = @"";
                }else
                {
                   // timeText = [NSString stringWithFormat:@"%ld %@",(long)secd,[SharedLanguages CustomLocalizedStringWithKey:@"TimeSec"]];
                }
            }else
            {
              //  timeText = [NSString stringWithFormat:@"%ld %@",(long)mins,[SharedLanguages CustomLocalizedStringWithKey:@"TimeMin"]];
            }
        }else
        {
          //  timeText = [NSString stringWithFormat:@"%ld %@",(long)hour,[SharedLanguages CustomLocalizedStringWithKey:@"TimeHour"]];
        }
    }else
    {
       // timeText = [NSString stringWithFormat:@"%ld %@",(long)day,[SharedLanguages CustomLocalizedStringWithKey:@"TimeDay"]];
    }
    
    return timeText;
}

+(NSString *)updateTimeLabelWithTimeString:(long long)endTime currentTime:(long long)currentTime;
{
    NSString *timeText = @"";
    long long latime = endTime - currentTime;
    NSInteger day = latime/(60 * 24 * 60);
    if (day == 0) {
        NSInteger hour = latime/(60 * 60);
        if (hour == 0) {
            NSInteger mins = latime /60;
            if (mins == 0) {
                NSInteger secd = latime;
                if (secd == 0) {
                    timeText = @"";
                }else
                {
                    //timeText = [NSString stringWithFormat:@"%ld %@",(long)secd,[SharedLanguages CustomLocalizedStringWithKey:@"RestTimeSecond"]];
                }
            }else
            {
               // timeText = [NSString stringWithFormat:@"%ld %@",(long)mins,[SharedLanguages CustomLocalizedStringWithKey:@"RestTimeMinute"]];
            }
        }else
        {
            //timeText = [NSString stringWithFormat:@"%ld %@",(long)hour,[SharedLanguages CustomLocalizedStringWithKey:@"RestTimeHour"]];
        }
    }else
    {
        //timeText = [NSString stringWithFormat:@"%ld %@",(long)day,[SharedLanguages CustomLocalizedStringWithKey:@"RestTimeDay"]];
    }
    
    return timeText;
}
+(NSString*)GetLastSixMonthData{
    NSString *timeString = @"";
    NSDate *now = [NSDate date];
    
    NSTimeInterval time = 180 * 24 * 60 * 60;//一年的秒数
    NSDate * lastSixMonth = [now dateByAddingTimeInterval:-time];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:lastSixMonth];
    long year = [dateComponent year];
    long month = [dateComponent month];
    long day = [dateComponent day];
    
    timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%ld-",year]];
    if (month < 10) {
        timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"0%ld-",month]];
    }else
    {
        timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%ld-",month]];
    }
    
    if (day < 10) {
        timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"0%ld",day]];
    }else
    {
        timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%ld",day]];
    }
    return timeString;
}

+ (NSString *)GetCurrentDate_
{
    NSString *timeString = @"";
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    long year = [dateComponent year];
    long month = [dateComponent month];
    long day = [dateComponent day];
    
    timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%ld-",year]];
    if (month < 10) {
        timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"0%ld-",month]];
    }else
    {
        timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%ld-",month]];
    }
    
    if (day < 10) {
        timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"0%ld",day]];
    }else
    {
        timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%ld",day]];
    }
    return timeString;
}
+ (NSString *)intervalSinceNowValueVip: (long long)passTime  SVip:(long long)spassTime
{
    
     NSDate *dateVip = [NSDate dateWithTimeIntervalSince1970:passTime/1000];
     NSTimeInterval timeVip  = [dateVip timeIntervalSince1970];
    
     NSDate *dateSVip = [NSDate dateWithTimeIntervalSince1970:spassTime/1000];
     NSTimeInterval timesSVip  = [dateSVip timeIntervalSince1970];
     NSTimeInterval currenttime = [[NSDate date] timeIntervalSince1970];
     NSTimeInterval space = timeVip - currenttime;
    
     NSTimeInterval  newInterval = timesSVip + space;
    
    
     NSDate *dd = [NSDate dateWithTimeIntervalSince1970:newInterval];
    
    NSString *formatDate = nil;
    NSDateFormatter *AllFormater = [[NSDateFormatter alloc] init];
    
//    if (IsArabic) {
//        [AllFormater setDateFormat:@"yyyy-MM-dd"];
//    }else{
        [AllFormater setDateFormat:@"dd-MM-yyyy"];
 //   }
    
    [AllFormater setTimeZone:[NSTimeZone localTimeZone]];
//    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSince1970:startTime];
    formatDate = [AllFormater stringFromDate:dd];
    return formatDate;
    
}

+ (NSString *)intervalSinceNow: (long long)passTime
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:passTime/1000];
    NSString *newsDate = [dateFormatter stringFromDate:confromTimesp];
    
   //NSLog(@"newsDate = %@",newsDate);
    NSDate *newsDateFormatted = [dateFormatter dateFromString:newsDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    
    NSDate* current_date = [[NSDate alloc] init];
    
    NSTimeInterval time = [current_date timeIntervalSinceDate:newsDateFormatted];//间隔的秒数
    
    int month=((int)time)/(3600*24*30);
    int days=((int)time)/(3600*24);
    int hours=((int)time)%(3600*24)/3600;
    int minute=((int)time)%(3600*24)/60;
    //NSLog(@"time=%f",(double)time);
    
    NSString *dateContent;
    NSString *arAgoString =@"منذ"; //等价于ago
    
    if(month!=0){
        
//        if (IsArabic) {
//            dateContent = [NSString stringWithFormat:@"%@ 3 %@",arAgoString,@"يوم"];
//        }else{
           // dateContent = [NSString stringWithFormat:@"3 %@ %@",[SharedLanguages CustomLocalizedStringWithKey:@"minDays"],[SharedLanguages CustomLocalizedStringWithKey:@"ago"]];
     //   }
        
        //dateContent = [NSString stringWithFormat:@"%i%@",month,@"个月前"];
        
    }
    else if(days!=0){
        if (days/3>0) {
            days =3;
        }
        
//        if (IsArabic) {
//            dateContent = [SharedLanguages CustomLocalizedStringWithKey:@"DaysAgo"];
//            dateContent = [dateContent stringByReplacingOccurrencesOfString:@"(0)" withString:[NSString stringWithFormat:@"%i",days]];
//
//        }else{
//            NSString *dayStr = [SharedLanguages CustomLocalizedStringWithKey:@"minDays"];
//            if (days < 2) {
//               // dayStr =  [SharedLanguages CustomLocalizedStringWithKey:@"minDay"];
//            }
//            dateContent = [NSString stringWithFormat:@"%i %@ %@",days,dayStr,[SharedLanguages CustomLocalizedStringWithKey:@"ago"]];
     //   }
        
        //NSLog(@"month-----%i",days);
    }else if(hours!=0){
//        NSString *hourStr = [SharedLanguages CustomLocalizedStringWithKey:@"TimeHours"];
//        if (hours < 2) {
//            hourStr =  [SharedLanguages CustomLocalizedStringWithKey:@"TimeHour"];
//        }
//        
//        if (IsArabic) {
// 
//            dateContent = [SharedLanguages CustomLocalizedStringWithKey:@"HoursAgo"];
//            dateContent = [dateContent stringByReplacingOccurrencesOfString:@"(1)" withString:[NSString stringWithFormat:@"%i",hours]];
//        }else{
//        
//            dateContent = [NSString stringWithFormat:@"%i %@ %@",hours,hourStr,[SharedLanguages CustomLocalizedStringWithKey:@"ago"]];
//        }
    }else {
//        NSString *minStr = [SharedLanguages CustomLocalizedStringWithKey:@"TimeMins"];
//        if (minute < 2) {
//            minStr = [SharedLanguages CustomLocalizedStringWithKey:@"TimeMin"];
//        }
//        
//        if (IsArabic) {
//            dateContent = [SharedLanguages CustomLocalizedStringWithKey:@"MinuteAgo"];
//            dateContent = [dateContent stringByReplacingOccurrencesOfString:@"(2)" withString:[NSString stringWithFormat:@"%i",minute]];
//        }else{
//            dateContent = [NSString stringWithFormat:@"%i %@ %@",minute,minStr,[SharedLanguages CustomLocalizedStringWithKey:@"ago"]];
//        }
    }
    
    return dateContent;
}
+(NSString *)timeformatHHMMAMPM:(long long)startTime
{
    NSString *formatDate = nil;
    NSDateFormatter *AllFormater = [[NSDateFormatter alloc] init];
    
    [AllFormater setDateFormat:@"h:mm a"];
    NSCalendar *Gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [AllFormater setLocale:[Gregorian locale]];
    [AllFormater setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSince1970:startTime];
    formatDate = [AllFormater stringFromDate:curDate];
    return [NSString localTimeFormat:formatDate];
}
//+(BOOL)dateIsToday:(long long)time{
//    NSDate *timeDate = [[NSDate alloc] initWithTimeIntervalSince1970:time];
//    return [timeDate isToday];
//}
//+(BOOL)dateIsYesterday:(long long)time{
//    NSDate *timeDate = [[NSDate alloc] initWithTimeIntervalSince1970:time];
//    return [timeDate isYesterday];
//}
+(NSString *)englishTimeWithTime:(long long)time showToday:(BOOL)showToday{
    if(time == 0){
        return @"";
    }
//    BOOL timeIsToady = [NSString dateIsToday:time];
//    if (timeIsToady) {
//        if(!showToday)
//            return [NSString timeformatHHMMAMPM:time];
//        else{
//            NSString *timeBlank = [[SharedLanguages CustomLocalizedStringWithKey:@"Today"] stringByAppendingString:@" "];
//            
//            return [timeBlank stringByAppendingString:[NSString timeformatHHMMAMPM:time]];
//        }
//    }
//    
//    BOOL timeIsYesterday = [NSString dateIsYesterday:time];
//    if (timeIsYesterday) {
//        NSString *yesterday = [[SharedLanguages CustomLocalizedStringWithKey:@"Yesterday"] stringByAppendingString:@" "];
//        NSString *yesterhour = [NSString timeformatHHMMAMPM:time];
//        NSString *final = [yesterday stringByAppendingString:yesterhour];
//        return final;
//    }
    
    NSString *finalTime = [NSString covertTimeAllFormatAMPM:time];
    return finalTime;
}
+(NSString *)covertTimeAllFormatAMPM:(long long)time{
    NSString *formatDate = nil;
    NSDateFormatter *AllFormater = [[NSDateFormatter alloc] init];
    [AllFormater setDateFormat:@"yyyy-MM-dd h:mm a"];
    NSCalendar *Gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [AllFormater setLocale:[Gregorian locale]];
    [AllFormater setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSince1970:time];
    formatDate = [AllFormater stringFromDate:curDate];
    
    return [NSString localTimeFormat:formatDate];
}

+(NSString *)localTimeFormat:(NSString *)formatDate{
    
//    if([formatDate rangeOfString:@"AM"].location != NSNotFound){
//        formatDate = [formatDate stringByReplacingOccurrencesOfString:@"AM" withString:[SharedLanguages CustomLocalizedStringWithKey:@"TimeAM"]];
//    }else if ([formatDate rangeOfString:@"am"].location != NSNotFound){
//        formatDate = [formatDate stringByReplacingOccurrencesOfString:@"am" withString:[SharedLanguages CustomLocalizedStringWithKey:@"TimeAM"]];
//    }
//    
//    if([formatDate rangeOfString:@"PM"].location != NSNotFound){
//        formatDate = [formatDate stringByReplacingOccurrencesOfString:@"PM" withString:[SharedLanguages CustomLocalizedStringWithKey:@"TimePM"]];
//    }else if ([formatDate rangeOfString:@"pm"].location != NSNotFound){
//        formatDate = [formatDate stringByReplacingOccurrencesOfString:@"pm" withString:[SharedLanguages CustomLocalizedStringWithKey:@"TimePM"]];
//    }
    return formatDate;
}
+(NSString *)lastTimeWithOutZeroStart:(long long)lastTime{
    // lastTime 秒数
    NSString *finalString = @"";
    NSInteger day = lastTime/60/60/24;
    NSInteger hours = lastTime/60/60%24;
    NSInteger mins = lastTime/60%60;
    NSInteger secs = lastTime%60;

    if (day != 0) {
        NSString *s = [NSString stringWithFormat:@"%02ld:%02ld:%02ld:%02ld",day,hours,mins,secs];
        finalString = [finalString stringByAppendingString:s];
    }else{
            NSString *s = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hours,mins,secs];
            finalString = [finalString stringByAppendingString:s];
    }
    return finalString;
}
+(NSString *)lastTimeWithOutZeroStartWithUnit:(long long)lastTime{
    // lastTime 秒数
    NSString *finalString = @"";
    NSInteger day = lastTime/60/60/24;
    NSInteger hours = lastTime/60/60%24;
    NSInteger mins = lastTime/60%60;
    NSInteger secs = lastTime%60;
    
//    NSString *dayUnit = [SharedLanguages CustomLocalizedStringWithKey:@"ActivityTimeDay"];
//    NSString *hourUint = [SharedLanguages CustomLocalizedStringWithKey:@"ActivityTimeHour"];
//    NSString *minUint = [SharedLanguages CustomLocalizedStringWithKey:@"ActivityTimeMinute"];
//    NSString *secUint = [SharedLanguages CustomLocalizedStringWithKey:@"ActivityTimeSecond"];

//    NSString *dayStr = [NSString stringWithFormat:@"%02ld %@",day,dayUnit];
//    NSString *hourStr = [NSString stringWithFormat:@"%02ld %@",hours,hourUint];
//    NSString *minStr = [NSString stringWithFormat:@"%02ld %@",mins,minUint];
//    NSString *secStr = [NSString stringWithFormat:@"%02ld %@",secs,secUint];
//    NSMutableArray *time = [NSMutableArray array];
//    if (day != 0) {
//        [time addObjectsFromArray:@[dayStr,hourStr,minStr,secStr]];
//    }else{
//        if (hours != 0) {
//            [time addObjectsFromArray:@[hourStr,minStr,secStr]];
//        }else{
//            if (mins != 0) {
//                [time addObjectsFromArray:@[minStr,secStr]];
//            }else{
//                [time addObjectsFromArray:@[secStr]];
//            }
//        }
//    }
    
   // finalString = [time componentsJoinedByString:IsArabic?@" : ":@" : "];
    return finalString;
}
@end
