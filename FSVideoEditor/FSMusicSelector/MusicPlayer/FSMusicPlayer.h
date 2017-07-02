//
//  FSMusicPlayer.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/30.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface FSMusicPlayer : NSObject
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,assign)CGFloat rate;

+(instancetype)sharedPlayer;

-(void)pause;
-(void)stop;
-(void)play;
-(void)playAtTime:(NSTimeInterval)atTime;

-(BOOL)isPlaying;
- (NSTimeInterval)soundTotalTime;
@end
