//
//  FSShortLanguage.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/18.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"

@implementation FSShortLanguage

+ (NSString *)CustomLocalizedStringFromTable:(NSString *)key {
    NSString *table = [[NSUserDefaults standardUserDefaults] valueForKey:@"LanguageTable"];
    if (table == nil) {
        table = @"Localizable";
    }
    
    NSString *RecoursePath = [FSPublishSingleton sharedInstance].language;
    NSString *PathString = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",RecoursePath] ofType:@"lproj"];

    if (PathString.length == 0) { //没有这种语言 默认取系统偏好
        
        NSString *perferredLanguage =  @"ar"; //[[NSLocale preferredLanguages] objectAtIndex:0];
        if ([perferredLanguage isEqualToString:@"zh-Hans"]) {
            perferredLanguage = @"ar";
        }
        PathString = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",perferredLanguage] ofType:@"lproj"];
    }
    
    NSBundle * currentBundle = [NSBundle bundleWithPath:PathString];
    NSString * LoaclizedString = [currentBundle localizedStringForKey:key value:nil table:table];
    
    return LoaclizedString;
    
//    if (!table) {
//        return NSLocalizedString(key, nil);
//    }
//    else {
//        return NSLocalizedStringFromTable(key, table, nil);
//    }
}

+ (void)setLanguageTable:(NSString *)table {
    [[NSUserDefaults standardUserDefaults] setValue:table forKey:@"LanguageTable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
