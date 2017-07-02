//
//  FSMusicPlayer.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/30.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicPlayer.h"


@interface FSMusicPlayer()

@property(nonatomic,strong)AVAudioPlayer *musicPlayer;

@end
@implementation FSMusicPlayer
static id object = nil;
+(instancetype)sharedPlayer{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!object) {
            object = [[self alloc] init];
        }
    });
    return object;
}
+(id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [super allocWithZone:zone];
    });
    return object;
}
+ (id)copyWithZone:(struct _NSZone *)zone
{
    return object;
}
-(void)setFilePath:(NSString *)filePath{
    _filePath = filePath;
    
    NSLog(@"file Path %@",filePath);
    
    NSData *mp3Data = [NSData dataWithContentsOfFile:filePath];
    
    if (!mp3Data) {
        NSLog(@"文件地址错误");
        return;
    }
    
    if (_musicPlayer) {
        [_musicPlayer stop];
    }
    
    _musicPlayer = [[AVAudioPlayer alloc] initWithData:mp3Data fileTypeHint:AVFileTypeMPEGLayer3 error:nil];
    [_musicPlayer prepareToPlay];
    [_musicPlayer setVolume:1.0];
}
-(void)setRate:(CGFloat)rate{
    _rate = rate;
    
    [_musicPlayer setEnableRate:YES];
    [_musicPlayer setRate:rate];
}
-(void)play{
    if ([_musicPlayer isPlaying]) {
        return;
    }
    
    [_musicPlayer play];
}

-(void)stop{
    if (![_musicPlayer isPlaying]) {
        return;
    }
    
    [_musicPlayer play];
}
-(void)pause{
    [_musicPlayer pause];
}
-(BOOL)isPlaying{
    return _musicPlayer.isPlaying;
}
-(void)playAtTime:(NSTimeInterval)atTime{
    [_musicPlayer playAtTime:atTime];
}
@end
