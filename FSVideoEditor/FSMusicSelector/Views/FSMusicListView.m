//
//  FSMusicListView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/26.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicListView.h"
#import "FSMusicPlayer.h"
#import "FSMusicManager.h"
#import "FSEditorLoading.h"
#import "FSVideoEditorCommenData.h"
#import "FSGlobalRefreshFooter.h"
#import "FSDraftManager.h"
#import "FSPublishSingleton.h"

@interface FSMusicListView ()<UITableViewDelegate,UITableViewDataSource,FSMusicCellDelegate,FSMusicCollectSeverDelegate>
{
    FSMusic *_music;
    FSMusicCollectSever *_collectSever;
}
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)FSEditorLoading *loading;
@end

@implementation FSMusicListView
-(FSEditorLoading *)loading{
    if (!_loading) {
        _loading = [[FSEditorLoading alloc] initWithFrame:self.bounds];
    }
    return _loading;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:(UITableViewStylePlain)];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setTableFooterView:[UIView new]];
        [self addSubview:_tableView];
         _collectSever = [FSMusicCollectSever new];
        [_collectSever setDelegate:self];
        [_tableView setMj_footer:[FSGlobalRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMoreData)]];
    }
    return self;
}
-(void)getMoreData{
    if ([self.delegate respondsToSelector:@selector(musicListWouldGetMoreData:)]) {
        [self.delegate musicListWouldGetMoreData:self];
    }
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    [_tableView setFrame:self.bounds];
}
-(void)setMusics:(NSArray *)musics{
     _musics = musics;

    [_tableView reloadData];
    if([_tableView.mj_footer isRefreshing]){
       [_tableView.mj_footer endRefreshing];
    }
}
-(void)insertMoreMusic:(NSArray *)musics{
    _musics = _musics?:[@[] mutableCopy];
    NSMutableArray *oldMusic = [NSMutableArray arrayWithArray:_musics];
    [oldMusic addObjectsFromArray:musics];
    [self setMusics:oldMusic];
}
-(void)setTableHeader:(UIView *)tableHeader{
    _tableHeader = tableHeader;
    [_tableView setTableHeaderView:tableHeader];
}
#pragma mark - 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_musics count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FSMusicCell *cell = [FSMusicCell musicCellWithTableView:tableView indexPath:indexPath];
    [cell setDelegate:self];
    FSMusic *music = [_musics objectAtIndex:indexPath.row];
    [cell setMusic:music];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FSMusic *music = [_musics objectAtIndex:indexPath.row];
    
    if (music.opend) {
        return 147.0;
    }
    return 107.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FSMusic *music = [_musics objectAtIndex:indexPath.row];
    // cell 动画
    [self tableView:tableView updateTableWithMusic:music selectIndexPath:indexPath];
    // 播放
    FSMusicCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self playMusic:music playViewCell:cell];
}
-(void)playMusic:(FSMusic *)music playViewCell:(FSMusicCell *)cell{
    //
    if ([_music isEqual:music]) {
        // 相同的音乐
        [cell setIsPlayIng:!cell.isPlayIng];
        
        if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
            [[FSMusicPlayer sharedPlayer] pause];
        }else{
            [[FSMusicPlayer sharedPlayer] play];
        }
    }else{
        //
        if (_music) {
            NSInteger index = [_musics indexOfObject:_music];
            NSIndexPath *IndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            FSMusicCell *preCell = [self.tableView cellForRowAtIndexPath:IndexPath];
            [preCell setIsPlayIng:NO];
        }
        
        [self addSubview:self.loading];
        [self.loading loadingViewShow];
        [cell setIsPlayIng:YES];
        [[FSMusicPlayer sharedPlayer] stop];

        if (music.songUrl) {
            
            NSString *url = music.songUrl;
            if (![url hasPrefix:@"http"] && url) {
                //@"http://35.158.218.231/"    http://10.10.32.152:20000/
                url = [AddressIP stringByAppendingString:music.songUrl];
            }
            __weak typeof(self) weakS = self;
            [FSMusicManager downLoadMusic:url complete:^(NSString *localPath, NSError *error) {
                [weakS.loading loadingViewhide];
                
                if (!error) {
                    [[FSMusicPlayer sharedPlayer] stop];
                    [[FSMusicPlayer sharedPlayer] setFilePath:localPath];
                }else{
                    return ;
                }
                
                if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
                    [[FSMusicPlayer sharedPlayer] pause];
                    [cell setIsPlayIng:NO];
                }else{
                    [[FSMusicPlayer sharedPlayer] play];
                    [cell setIsPlayIng:YES];

                }
            }];
        }
    }
    // 更新当前选中的音乐
    _music = music;
}
#pragma mark -
-(void)tableView:(UITableView *)tableView updateTableWithMusic:(FSMusic *)music selectIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableArray *paths = [NSMutableArray array];
    if (![_music isEqual:music]) {
        NSIndexPath *selectedPath = nil;
        if (_music) {
            NSInteger index = [_musics indexOfObject:_music];
            selectedPath = [NSIndexPath indexPathForRow:index inSection:0];
            _music.opend =  NO;
        }
        music.opend = YES;
        if (selectedPath) {
            [paths addObject:selectedPath];
        }
        [paths addObject:indexPath];

    }else{
        _music.opend = YES;
        NSMutableArray *paths = [NSMutableArray array];
        [paths addObject:indexPath];
        
        FSMusicCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setMusic:_music];
    }
    
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:paths withRowAnimation:(UITableViewRowAnimationFade)];
    [tableView endUpdates];

}
-(void)musicCell:(FSMusicCell *)cell wouldPlay:(FSMusic *)music{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [self tableView:self.tableView updateTableWithMusic:music selectIndexPath:indexPath];
    
    [self playMusic:music playViewCell:cell];
}

-(void)musicCell:(FSMusicCell *)cell wuoldUseMusic:(FSMusic *)music{
    NSString *path = nil;
    if (music.songUrl) {
        NSString *localPath = [FSMusicManager musicPathWithFileName:music.songUrl];
        path = localPath;
    }else{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:music.songTitle ofType:@"mp3"];
        path = bundlePath;
    }
    [cell setIsPlayIng:NO];
    [[FSMusicPlayer sharedPlayer] stop];
    
    FSDraftMusic *draftMusic = [[FSDraftMusic alloc] initWithMusic:music];
    FSDraftInfo *tempInfo = [[FSDraftManager sharedManager] draftInfoWithPreInfo:nil];
    tempInfo.vMusic = draftMusic;
    [[FSDraftManager sharedManager] mergeInfo];
    
    if ([self.delegate respondsToSelector:@selector(musicListWouldUseMusic:musicPath:)]) {
        [self.delegate musicListWouldUseMusic:music musicPath:path];
    }
}
-(void)musicCell:(FSMusicCell *)cell wouldShowDetail:(FSMusic *)music{
    if ([self.delegate respondsToSelector:@selector(musicListWouldShowDetail:)]) {
        [self.delegate musicListWouldShowDetail:music];
    }
}
-(void)musicCell:(FSMusicCell *)cell wouldCollect:(FSMusic *)music{
    [_collectSever collectMusic:music collect:music.collected];
}
#pragma mark - 
-(void)musicCollectSeverCollectMusicSuccess:(FSMusic *)music{
    [self.delegate musicListUpdateCollectState:music];

//    [_tableView reloadData];
    //if (music.collected == NO) {
//        for (FSMusic *oldMusic in _musics) {
//            if (oldMusic.songId == music.songId) {
//                oldMusic.collected = music.collected;
//            }
//        }
  //  }
    
    NSLog(@"收藏成功!");
}
-(void)musicCollectSeverCollectFaild:(FSMusic *)music{
    music.collected = !music.collected;
    [_tableView reloadData];
}
#pragma mark -

#pragma mark - 
-(void)showLoading:(BOOL)show{
    if (show) {
        [self.loading loadingViewShow];
        [self addSubview:self.loading];
    }else{
        [self.loading loadingViewhide];
    }
}
- (void)stopPlayCurrentMusic {
    if (_music && _music.isPlaying) {
        _music.isPlaying = NO;
        _music.opend = NO;
        [[FSMusicPlayer sharedPlayer] stop];
    }

    [_tableView reloadData];
}
@end
