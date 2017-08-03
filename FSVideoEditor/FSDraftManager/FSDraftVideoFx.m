//
//  FSVideoFx.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftVideoFx.h"

@implementation FSDraftVideoFx

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        self.vFxId = [[aDecoder decodeObjectForKey:@"vFxId"] intValue];
        self.vFxInPoint = [[aDecoder decodeObjectForKey:@"vFxInPoint"] longLongValue];
        self.vFxOutPoint = [[aDecoder decodeObjectForKey:@"vFxOutPoint"] longLongValue];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:[NSNumber numberWithInt:self.vFxId] forKey:@"vFxId"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:self.vFxInPoint] forKey:@"vFxInPoint"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:self.vFxOutPoint] forKey:@"vFxOutPoint"];
}

-(id)copyWithZone:(NSZone *)zone{
    
    FSDraftVideoFx *draftVideoFx = [FSDraftVideoFx allocWithZone:zone];
    draftVideoFx -> _vFxId = self.vFxId;
    draftVideoFx -> _vFxInPoint = self.vFxInPoint;
    draftVideoFx -> _vFxOutPoint = self.vFxOutPoint;
    return draftVideoFx;
}

@end
