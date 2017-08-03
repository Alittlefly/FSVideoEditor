//
//  FSDraftMusic.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftMusic.h"

@implementation FSDraftMusic

-(instancetype)initWithCoder:(NSCoder *)aDecoder{

    if (self = [super init]) {
        self.mPath = [aDecoder decodeObjectForKey:@"mPath"];
        self.mId = [[aDecoder decodeObjectForKey:@"mId"] intValue];
        self.mInPoint = [[aDecoder decodeObjectForKey:@"mInPoint"] longLongValue];
        self.mOutPoint = [[aDecoder decodeObjectForKey:@"mOutPoint"] longLongValue];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.mPath forKey:@"mPath"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.mId] forKey:@"mId"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:self.mInPoint] forKey:@"mInPoint"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:self.mOutPoint] forKey:@"mOutPoint"];
}
-(id)copyWithZone:(NSZone *)zone{
    
    FSDraftMusic *music = [FSDraftMusic allocWithZone:zone];
    music -> _mPath = self.mPath;
    music -> _mId = self.mId;
    music -> _mInPoint = self.mInPoint;
    music -> _mOutPoint = self.mOutPoint;
    return music;
}

@end
