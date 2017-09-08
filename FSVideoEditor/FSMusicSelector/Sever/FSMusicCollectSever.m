//
//  FSMusicCollectSever.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicCollectSever.h"
#import "FSMusicCollectAPI.h"
#import "FSLikedMusicAPI.h"
#import "FSPublishSingleton.h"
@interface FSMusicCollectSever ()<FSMusicCollectAPIDelegate,FSLikedMusicAPIDelegate>
{
    FSLikedMusicAPI *_likedApi;
}
@property(nonatomic,strong)NSMutableArray *taskSets;
@end

@implementation FSMusicCollectSever
-(NSMutableArray *)taskSets{
    if (!_taskSets) {
        _taskSets = [NSMutableArray array];
    }
    return _taskSets;
}
-(void)collectMusic:(FSMusic *)music collect:(BOOL)collect{
    FSMusicCollectAPI *musicCollectAPI = [FSMusicCollectAPI new];
    [musicCollectAPI setDelegate:self];
    [musicCollectAPI collectMusic:music.songId collect:collect];
    [musicCollectAPI setMusic:music];
    NSLog(@"usicCollectAPI.taskId :%@",musicCollectAPI.taskId);
    [self.taskSets addObject:musicCollectAPI];
}
-(void)getLikedMusicsList:(NSInteger)fromPage{
    if (!_likedApi) {
         _likedApi = [FSLikedMusicAPI new];
        [_likedApi setDelegate:self];
    }
    [_likedApi getCollectedMusics:fromPage];
}
#pragma mark -
-(void)collectMusicSuccess:(FSMusicCollectAPI *)task{
    [self.taskSets removeObject:task];
    NSLog(@"taskSets :%@",self.taskSets);

    if ([[FSPublishSingleton sharedInstance].likeMusicArray containsObject:[NSString stringWithFormat:@"%ld",(long)task.music.songId]]) {
        [[FSPublishSingleton sharedInstance].likeMusicArray removeObject:[NSString stringWithFormat:@"%ld",(long)task.music.songId]];
    }
    else {
        [[FSPublishSingleton sharedInstance].likeMusicArray addObject:[NSString stringWithFormat:@"%ld",(long)task.music.songId]];
    }
    NSLog(@"asflasdlfasdfasd %@",[FSPublishSingleton sharedInstance].likeMusicArray);
    if([self.delegate respondsToSelector:@selector(musicCollectSeverCollectMusicSuccess:)]){
        [self.delegate musicCollectSeverCollectMusicSuccess:task.music];
    }
}
-(void)collectMusicFaild:(FSMusicCollectAPI *)task{
    [self.taskSets removeObject:task];
    if ([self.delegate respondsToSelector:@selector(musicCollectSeverCollectFaild:)]) {
        [self.delegate musicCollectSeverCollectFaild:task.music];
    }
}

#pragma mark -
-(void)likedMusicApigetMusics:(NSDictionary *)responseObjct{
    NSInteger code = [[responseObjct valueForKey:@"code"] integerValue];
    if (code == 0) {
        NSArray *musicsArray = [responseObjct valueForKey:@"dataInfo"];
        NSArray *musics = [FSMusic getDataArrayFromArray:musicsArray];
        
        for (FSMusic *music in musics) {
            music.collected = YES;
        }
        
        if ([self.delegate respondsToSelector:@selector(musicSeverGetCollectedMusics:)]) {
            [self.delegate musicSeverGetCollectedMusics:musics];
        }
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(musicSeverGetCollectedFaild)]) {
        [self.delegate musicSeverGetCollectedFaild];
    }
}
-(void)likedMusicApiGetFaild{
    if ([self.delegate respondsToSelector:@selector(musicSeverGetCollectedFaild)]) {
        [self.delegate musicSeverGetCollectedFaild];
    }
}
@end
