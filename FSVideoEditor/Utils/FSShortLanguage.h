//
//  FSShortLanguage.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/18.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSShortLanguage : NSObject

+ (NSString *)CustomLocalizedStringFromTable:(NSString *)key;
+ (void)setLanguageTable:(NSString *)table;


@end
