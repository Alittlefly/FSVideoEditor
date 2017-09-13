//
//  FSMusicPlayer.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/30.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicPlayer.h"

@interface FSMusicPlayer()
{
    CGFloat _volume;
}
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
-(instancetype)init{
    if (self = [super init]) {
        _volume = 1.0;
    }
    return self;
}
-(void)setFilePath:(NSString *)filePath{
    _filePath = filePath;
    
    if (_musicPlayer) {
        [_musicPlayer stop];
    }
    _musicPlayer = nil;
    
    NSData *mp3Data = [NSData dataWithContentsOfFile:filePath];
    
    if (!mp3Data) {
        NSLog(@"文件地址错误filePath:%@",filePath);
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        return;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    
    NSError *error;
     _musicPlayer = [[AVAudioPlayer alloc] initWithData:mp3Data fileTypeHint:AVFileTypeMPEGLayer3 error:&error];
    if (error) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }else{
        [_musicPlayer prepareToPlay];
        [_musicPlayer setNumberOfLoops:-1];
        [_musicPlayer setVolume:_volume];
    }
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
    
    [_musicPlayer prepareToPlay];
    [_musicPlayer play];
}

-(void)stop{
    if (![_musicPlayer isPlaying]) {
        return;
    }
    
    [_musicPlayer stop];
}
-(void)pause{
    [_musicPlayer pause];
}
-(BOOL)isPlaying{
    return _musicPlayer.isPlaying;
}

- (NSTimeInterval)soundTotalTime {
    return _musicPlayer.duration;
}

-(void)playAtTime:(NSTimeInterval)atTime{
    if (atTime > _musicPlayer.duration) {
        return;
    }
    _musicPlayer.currentTime = atTime;
    //[_musicPlayer playAtTime:atTime];
}

- (void)changeVolume:(CGFloat)value {
    _volume = value;
    [_musicPlayer setVolume:value];
}

@end
