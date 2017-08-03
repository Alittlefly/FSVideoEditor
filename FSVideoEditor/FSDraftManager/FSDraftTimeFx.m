//
//  FSTimeFx.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftTimeFx.h"

@implementation FSDraftTimeFx

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        self.tFxType = [[aDecoder decodeObjectForKey:@"tFxType"] integerValue];
        self.tFxInPoint = [[aDecoder decodeObjectForKey:@"tFxInPoint"] longLongValue];
        self.tFxInPoint = [[aDecoder decodeObjectForKey:@"tFxOutPoint"] longLongValue];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:[NSNumber numberWithInteger:self.tFxType] forKey:@"tFxType"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:self.tFxInPoint] forKey:@"tFxInPoint"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:self.tFxOutPoint] forKey:@"tFxOutPoint"];
}

-(id)copyWithZone:(NSZone *)zone{
    
    FSDraftTimeFx *draftTimeFx = [FSDraftTimeFx allocWithZone:zone];
    draftTimeFx.tFxType = self.tFxType;
    draftTimeFx.tFxInPoint = self.tFxInPoint;
    draftTimeFx.tFxOutPoint = self.tFxOutPoint;
    return draftTimeFx;
}

@end
