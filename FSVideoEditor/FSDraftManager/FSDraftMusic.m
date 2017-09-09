//
//  FSDraftMusic.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftMusic.h"

@implementation FSDraftMusic
-(instancetype)initWithMusic:(FSMusic *)music{
    if (self = [super init]) {
        self.mId = music.songId;
        self.mName = music.songTitle;
        self.mPic = music.songPic;
        self.mAutor = music.songAuthor;
        self.mInPoint = 0;
        self.mOutPoint = music.lastSeconds;
        self.mUrl = music.songUrl;
    }
    return self;
}
-(FSMusic *)orginalMusic{
    FSMusic *music = [[FSMusic alloc] init];
    music.songId = self.mId;
    music.songTitle = self.mName;
    music.songPic = self.mPic;
    music.lastSeconds = self.mOutPoint;
    music.songUrl = self.mUrl;
    
    return music;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{

    if (self = [super init]) {
        self.mUrl = [aDecoder decodeObjectForKey:@"mUrl"];
        self.mId = [[aDecoder decodeObjectForKey:@"mId"] integerValue];
        self.mInPoint = [[aDecoder decodeObjectForKey:@"mInPoint"] longLongValue];
        self.mOutPoint = [[aDecoder decodeObjectForKey:@"mOutPoint"] longLongValue];
        self.mAutor = [aDecoder decodeObjectForKey:@"mAutor"];
        self.mName = [aDecoder decodeObjectForKey:@"mName"];
        self.mPic = [aDecoder decodeObjectForKey:@"mPic"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.mUrl forKey:@"mUrl"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.mId] forKey:@"mId"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:self.mInPoint] forKey:@"mInPoint"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:self.mOutPoint] forKey:@"mOutPoint"];
    [aCoder encodeObject:self.mAutor forKey:@"mAutor"];
    [aCoder encodeObject:self.mName forKey:@"mName"];
    [aCoder encodeObject:self.mPic forKey:@"mPic"];
}
-(id)copyWithZone:(NSZone *)zone{
    
    FSDraftMusic *music = [FSDraftMusic allocWithZone:zone];
    music.mId = self.mId;
    music.mInPoint = self.mInPoint;
    music.mOutPoint = self.mOutPoint;
    music.mUrl = self.mUrl;
    music.mAutor = self.mAutor;
    music.mName = self.mName;
    music.mPic = self.mPic;
    
    return music;
}
-(NSString *)mPath{
    _mPath = [FSMusicManager musicPathWithFileName:self.mUrl];
    return _mPath;
}

@end
