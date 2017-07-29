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
@interface FSMusicCollectSever ()<FSMusicCollectAPIDelegate,FSLikedMusicAPIDelegate>
{
    FSLikedMusicAPI *_likedApi;
}
@property(nonatomic,strong)NSMutableDictionary *taskSets;
@end

@implementation FSMusicCollectSever
-(NSMutableDictionary *)taskSets{
    if (!_taskSets) {
        _taskSets = [NSMutableDictionary dictionary];
    }
    return _taskSets;
}
-(void)collectMusic:(FSMusic *)music collect:(BOOL)collect{
    FSMusicCollectAPI *musicCollectAPI = [FSMusicCollectAPI new];
    [musicCollectAPI setDelegate:self];
    [musicCollectAPI collectMusic:music.songId collect:collect];
    [musicCollectAPI setMusic:music];
    [self.taskSets setValue:musicCollectAPI forKey:musicCollectAPI.taskId];
}
-(void)getLikedMusicsList:(NSInteger)fromPage{
    if (!_likedApi) {
         _likedApi = [FSLikedMusicAPI new];
        [_likedApi setDelegate:self];
    }
    [_likedApi getCollectedMusics:fromPage];
}
#pragma mark -
-(void)collectMusicSuccess:(NSString *)taskId{
    FSMusicCollectAPI *api = [self.taskSets valueForKey:taskId];
    [self.taskSets removeObjectForKey:taskId];
    if([self.delegate respondsToSelector:@selector(musicCollectSeverCollectMusicSuccess:)]){
        [self.delegate musicCollectSeverCollectMusicSuccess:api.music];
    }
}
-(void)collectMusicFaild:(NSString *)taskId{
    FSMusicCollectAPI *api = [self.taskSets valueForKey:taskId];
    [self.taskSets removeObjectForKey:taskId];
    if ([self.delegate respondsToSelector:@selector(musicCollectSeverCollectFaild:)]) {
        [self.delegate musicCollectSeverCollectFaild:api.music];
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
