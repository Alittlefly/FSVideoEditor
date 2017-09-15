//
//  FSTimeLineInfo.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftInfo.h"

@interface FSDraftInfo(){
    NSString *_vFinalPath;
    NSString *_vOriginalPath;
    NSString *_vFirstFramePath;
    NSString *_vConvertPath;
    NSArray<NSString *> *_recordVideoPathArray;
}

@end

@implementation FSDraftInfo

-(instancetype)init{
    if (self = [super init]) {
        [self setVSpeed:1.0];
        [self setVMusicVolume:-1.0];
        [self setVOriginalVolume:-1.0];
        [self setVBeautyOn:YES];
        [self setIsFrontCamera:YES];
        [self setVSaveToAlbum:YES];
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
        self.vBeautyOn = draftInfo?draftInfo.vBeautyOn:YES;
        self.vOriginalVolume = draftInfo?draftInfo.vOriginalVolume:-1.0;
        self.vMusicVolume = draftInfo?draftInfo.vMusicVolume:-1.0;
        self.vFinalPath = draftInfo.vFinalPath;
        self.vSpeed = draftInfo?draftInfo.vSpeed:1.0;
        self.vFilterid = draftInfo.vFilterid;
        self.vConvertPath = draftInfo.vConvertPath;
        self.vFirstFramePath = draftInfo.vFirstFramePath;
        self.vSaveToAlbum = draftInfo?draftInfo.vSaveToAlbum:YES;
        self.vOriginalPath = draftInfo.vOriginalPath;
        self.recordVideoPathArray = draftInfo.recordVideoPathArray;
        self.recordVideoTimeArray = draftInfo.recordVideoTimeArray;
        self.recordVideoSpeedArray = draftInfo.recordVideoSpeedArray;
        self.vType = draftInfo.vType;
        self.vAddedFxViews = draftInfo.vAddedFxViews;
        self.isFrontCamera = draftInfo?draftInfo.isFrontCamera:YES;
    }
    return self;
}
-(void)copyValueFromeDraftInfo:(FSDraftInfo *)draftInfo{
    if (!draftInfo) {
        return;
    }
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
    self.vType = draftInfo.vType;
    self.vAddedFxViews = draftInfo.vAddedFxViews;
    self.isFrontCamera= draftInfo.isFrontCamera;
}
-(void)clearFxInfos{
    self.clips = nil;
    self.stack = nil;
    self.vSpeed = 1.0;
    self.vFilterid = 0;
    self.vOriginalVolume = -1.0;
    self.vMusicVolume = -1.0;
    self.vFirstFramePath = nil;
    self.vAddedFxViews = nil;
    self.vTimefx = nil;
    self.vBeautyOn = YES;
    self.isFrontCamera = YES;
    self.vSaveToAlbum = YES;
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
        self.vType = [[aDecoder decodeObjectForKey:@"vType"] integerValue];
        self.vAddedFxViews = [aDecoder decodeObjectForKey:@"vAddedFxViews"];
        self.isFrontCamera = [[aDecoder decodeObjectForKey:@"isFrontCamera"] boolValue];

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
    [aCoder encodeObject:[NSNumber numberWithInteger:self.vType] forKey:@"vType"];
    [aCoder encodeObject:self.vAddedFxViews forKey:@"vAddedFxViews"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isFrontCamera] forKey:@"isFrontCamera"];

}

- (void)setVFinalPath:(NSString *)vFinalPath {
    NSArray *filePathArray = [vFinalPath componentsSeparatedByString:@"Documents/"];
    _vFinalPath = [filePathArray lastObject];
}

- (void)setVOriginalPath:(NSString *)vOriginalPath {
    NSArray *filePathArray = [vOriginalPath componentsSeparatedByString:@"Documents/"];
    _vOriginalPath = [filePathArray lastObject];
}

- (void)setVConvertPath:(NSString *)vConvertPath {
    NSArray *filePathArray = [vConvertPath componentsSeparatedByString:@"Documents/"];
    _vConvertPath = [filePathArray lastObject];

}

- (void)setVFirstFramePath:(NSString *)vFirstFramePath {
    NSArray *filePathArray = [vFirstFramePath componentsSeparatedByString:@"Documents/"];
    _vFirstFramePath = [filePathArray lastObject];
}

- (NSString *)vFinalPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    return  _vFinalPath?[[paths objectAtIndex:0]stringByAppendingPathComponent:_vFinalPath]:_vFinalPath;
}

- (NSString *)vOriginalPath {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return _vOriginalPath?[[paths objectAtIndex:0] stringByAppendingPathComponent:_vOriginalPath]:_vOriginalPath;
}

- (NSString *)vConvertPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return  _vConvertPath?[[paths objectAtIndex:0]stringByAppendingPathComponent:_vConvertPath]:_vConvertPath;
}

- (NSString *)vFirstFramePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return  _vFirstFramePath?[[paths objectAtIndex:0]stringByAppendingPathComponent:_vFirstFramePath]:_vFirstFramePath;
}

- (void)setRecordVideoPathArray:(NSArray<NSString *> *)recordVideoPathArray {
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:0];
    for (NSString *path in recordVideoPathArray) {
         NSArray *filePathArray = [path componentsSeparatedByString:@"Documents/"];
        NSString *newPath = [filePathArray lastObject];
        [tmpArray addObject:newPath];
    }
    _recordVideoPathArray = [NSArray arrayWithArray:tmpArray];
}

- (NSArray<NSString *> *)recordVideoPathArray {
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:0];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    for (NSString *path in _recordVideoPathArray) {
        
        NSString *newPath = [[paths objectAtIndex:0]stringByAppendingPathComponent:path];
        [tmpArray addObject:newPath];
    }
    
    return tmpArray;
}

@end
