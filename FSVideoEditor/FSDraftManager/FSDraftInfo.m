//
//  FSTimeLineInfo.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftInfo.h"

@implementation FSDraftInfo

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        self.vMusic = [aDecoder decodeObjectForKey:@"vMusic"];
        self.stack = [aDecoder decodeObjectForKey:@"stack"];
        self.challenge = [aDecoder decodeObjectForKey:@"challenge"];
        self.vTimefx = [aDecoder decodeObjectForKey:@"vTimefx"];
        self.vBeautyOn = [[aDecoder decodeObjectForKey:@"vBeautyOn"] boolValue];
        self.vOriginalVolume = [[aDecoder decodeObjectForKey:@"vOriginalVolume"] doubleValue];
        self.vMusicVolume = [[aDecoder decodeObjectForKey:@"vMusicVolume"] doubleValue];
        self.vTitle = [aDecoder decodeObjectForKey:@"vTitle"];
        self.vFinalPath = [aDecoder decodeObjectForKey:@"vFinalPath"];
        self.vFirstFramePath = [aDecoder decodeObjectForKey:@"vFirstFramePath"];
        self.vSpeed = [[aDecoder decodeObjectForKey:@"vSpeed"] doubleValue];
        self.clips = [aDecoder decodeObjectForKey:@"clips"];
        self.vConvertPath = [aDecoder decodeObjectForKey:@"vConvertPath"];
        self.vFilterid = [aDecoder decodeObjectForKey:@"vFilterid"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.vMusic forKey:@"vMusic"];
    [aCoder encodeObject:self.stack forKey:@"stack"];
    [aCoder encodeObject:self.challenge forKey:@"challenge"];
    [aCoder encodeObject:self.vTimefx forKey:@"vTimefx"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.vBeautyOn] forKey:@"vBeautyOn"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.vOriginalVolume] forKey:@"vOriginalVolume"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.vMusicVolume] forKey:@"vMusicVolume"];
    [aCoder encodeObject:self.vTitle forKey:@"vTitle"];
    [aCoder encodeObject:self.vFinalPath forKey:@"vFinalPath"];
    [aCoder encodeObject:self.vFirstFramePath forKey:@"vFirstFramePath"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.vSpeed] forKey:@"vSpeed"];
    [aCoder encodeObject:self.clips forKey:@"clips"];
    [aCoder encodeObject:self.vConvertPath forKey:@"vConvertPath"];
    [aCoder encodeObject:self.vFilterid forKey:@"vFilterid"];
}


@end
