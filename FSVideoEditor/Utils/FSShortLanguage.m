//
//  FSShortLanguage.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/18.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSShortLanguage.h"

@implementation FSShortLanguage

+ (NSString *)CustomLocalizedStringFromTable:(NSString *)key {
    NSString *table = [[NSUserDefaults standardUserDefaults] valueForKey:@"LanguageTable"];
    

    if (!table) {
        table = @"Localizable";
    }

    NSString *RecoursePath = [[NSUserDefaults standardUserDefaults] valueForKey:@"Language"];
    if (!RecoursePath) {
        RecoursePath = [[[NSUserDefaults standardUserDefaults] valueForKey:@"Country"] isEqualToString:@"ar"] ? @"ar" : @"tr";
    }
    // 兼容 iOS 9.0
    if ([RecoursePath rangeOfString:@"en"].location != NSNotFound) {
        RecoursePath = @"en";
    }else if ([RecoursePath rangeOfString:@"ar"].location != NSNotFound) {
        RecoursePath = @"ar";
    }else if ([RecoursePath rangeOfString:@"tr"].location != NSNotFound) {
        RecoursePath = @"tr";
    }else
    {
        RecoursePath = @"en";
    }
    
    
    
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
    return LoaclizedString;//NSLocalizedStringFromTable(key, table, nil);
}

+ (void)setLanguageTable:(NSString *)table language:(NSString *)language {
    if (table) {
        [[NSUserDefaults standardUserDefaults] setValue:table forKey:@"LanguageTable"];
    }
    if (language) {
        [[NSUserDefaults standardUserDefaults] setValue:language forKey:@"Language"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
