//
//  FSDraftMusic.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftMusic.h"

@implementation FSDraftMusic
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[NSNumber numberWithLongLong:self.mOutPoint] forKey:@"mOutPoint"];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    FSDraftMusic *music = [FSDraftMusic new];
    music.mOutPoint = [[aDecoder decodeObjectForKey:@"mOutPoint"] longLongValue];
    return music;
}

@end
