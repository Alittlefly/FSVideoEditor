//
//  FSMusic.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusic.h"

@implementation FSMusic

+ (NSArray *)getDataArrayFromArray:(NSArray *)array
{
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dic in array) {
        FSMusic *music = [[FSMusic alloc] init];
        [music setSongId:[[dic objectForKey:@"sid"] integerValue]];
        [music setSongIndex:[[dic objectForKey:@"i"] integerValue]];
        [music setSongTitle:[dic objectForKey:@"n"]];
        [music setSongPic:[dic objectForKey:@"p"]];
        [music setSongUrl:[dic objectForKey:@"u"]];
        [music setSongAuthor:[dic objectForKey:@"a"]];
        [music setSongTime:[[dic objectForKey:@"l"] integerValue]];
        
        [dataArray addObject:music];
        
    }
    
    return dataArray;
}

@end
