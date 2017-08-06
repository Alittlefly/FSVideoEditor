//
//  FSTimeLineInfo.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftInfo.h"

@implementation FSDraftInfo

-(instancetype)init{
    if (self = [super init]) {
        [self setVSpeed:1.0];
    }
    return self;
}
-(instancetype)initWithDraftInfo:(FSDraftInfo *)draftInfo{
    if (self = [super init]) {
        self.challenge = [draftInfo.challenge copy];
        self.vMusic = [draftInfo.vMusic copy];
        self.clips = [draftInfo.clips copy];
        self.vTimefx = [draftInfo.vTimefx copy];
        self.vTitle = draftInfo.vTitle;
        self.stack = [draftInfo.stack copy];
        self.vBeautyOn = draftInfo.vBeautyOn;
        self.vOriginalVolume = draftInfo.vOriginalVolume;
        self.vMusicVolume = draftInfo.vMusicVolume;
        self.vFinalPath = draftInfo.vFinalPath;
        self.vSpeed = draftInfo.vSpeed;
        self.vFilterid = draftInfo.vFilterid;
        self.vConvertPath = draftInfo.vConvertPath;
        self.vFirstFramePath = draftInfo.vFirstFramePath;
        self.vSaveToAlbum = draftInfo.vSaveToAlbum;
        self.vOriginalPath = draftInfo.vOriginalPath;
        self.recordVideoPathArray = draftInfo.recordVideoPathArray;
        self.recordVideoTimeArray = draftInfo.recordVideoTimeArray;
        self.recordVideoSpeedArray = draftInfo.recordVideoSpeedArray;

    }
    return self;
}
-(void)copyValueFromeDraftInfo:(FSDraftInfo *)draftInfo{
    self.challenge = draftInfo.challenge;
    self.vMusic = draftInfo.vMusic;
    self.clips = draftInfo.clips;
    self.vTimefx = draftInfo.vTimefx;
    self.vTitle = draftInfo.vTitle;
    self.stack = draftInfo.stack;
    self.vBeautyOn = draftInfo.vBeautyOn;
    self.vOriginalVolume = draftInfo.vOriginalVolume;
    self.vMusicVolume = draftInfo.vMusicVolume;
    self.vFinalPath = draftInfo.vFinalPath;
    self.vSpeed = draftInfo.vSpeed;
    self.vFilterid = draftInfo.vFilterid;
    self.vConvertPath = draftInfo.vConvertPath;
    self.vFirstFramePath = draftInfo.vFirstFramePath;
    self.vSaveToAlbum = draftInfo.vSaveToAlbum;
    self.vOriginalPath = draftInfo.vOriginalPath;
    self.recordVideoPathArray = draftInfo.recordVideoPathArray;
    self.recordVideoTimeArray = draftInfo.recordVideoTimeArray;
    self.recordVideoSpeedArray = draftInfo.recordVideoSpeedArray;

}

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
        self.vSaveToAlbum = [[aDecoder decodeObjectForKey:@"vSaveToAlbum"] boolValue];
        self.vOriginalPath = [aDecoder decodeObjectForKey:@"vOriginalPath"];
        self.recordVideoTimeArray = [aDecoder decodeObjectForKey:@"recordVideoTimeArray"];
        self.recordVideoPathArray = [aDecoder decodeObjectForKey:@"recordVideoPathArray"];
        self.recordVideoSpeedArray = [aDecoder decodeObjectForKey:@"recordVideoSpeedArray"];

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
    [aCoder encodeObject:self.recordVideoPathArray forKey:@"recordVideoPathArray"];
    [aCoder encodeObject:self.recordVideoTimeArray forKey:@"recordVideoTimeArray"];
    [aCoder encodeObject:self.recordVideoSpeedArray forKey:@"recordVideoSpeedArray"];
    [aCoder encodeObject:self.vConvertPath forKey:@"vConvertPath"];
    [aCoder encodeObject:self.vFilterid forKey:@"vFilterid"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.vSaveToAlbum] forKey:@"vSaveToAlbum"];
    [aCoder encodeObject:self.vOriginalPath forKey:@"vOriginalPath"];
}
@end
