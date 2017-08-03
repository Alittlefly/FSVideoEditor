//
//  FSVideoFx.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoFx.h"

@implementation FSVideoFx
-(id)copyWithZone:(NSZone *)zone{
    FSVideoFx *newFx = [FSVideoFx allocWithZone:zone];
    newFx -> _startPoint = self.startPoint;
    newFx -> _endPoint = self.endPoint;
    newFx -> _videoFxId = self.videoFxId;
    newFx -> _convert  = self.convert;
    return newFx;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        self.videoFxId = [aDecoder decodeObjectForKey:@"videoFxId"];
        self.startPoint = [[aDecoder decodeObjectForKey:@"startPoint"] longLongValue];
        self.endPoint = [[aDecoder decodeObjectForKey:@"endPoint"] longLongValue];
        self.convert = [[aDecoder decodeObjectForKey:@"convert"] boolValue];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.videoFxId forKey:@"videoFxId"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:self.startPoint] forKey:@"startPoint"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:self.endPoint] forKey:@"endPoint"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.convert] forKey:@"convert"];
}

@end
