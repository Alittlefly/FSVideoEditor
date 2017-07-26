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
        return NSLocalizedString(key, nil);
    }
    else {
        return NSLocalizedStringFromTable(key, table, nil);
    }
}

+ (void)setLanguageTable:(NSString *)table {
    [[NSUserDefaults standardUserDefaults] setValue:table forKey:@"LanguageTable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
