//
//  FSMusicController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/29.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicController.h"
#import "NvsStreamingContext.h"
#import "FSShortVideoRecorderController.h"
#import "FSMusicPlayer.h"
#import "FSMusicSever.h"
#import "FSMusicManager.h"
#import "FSEditorLoading.h"

@interface FSMusicController ()<UITableViewDelegate,UITableViewDataSource,FSMusicCellDelegate,FSMusicSeverDelegate>{
    FSMusic *_music;
    FSMusicSever *_sever;
}
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *musics;
@property(nonatomic,strong)FSEditorLoading *loading;

@end

@implementation FSMusicController

-(FSEditorLoading *)loading{
    if (!_loading) {
        _loading = [[FSEditorLoading alloc] initWithFrame:self.view.bounds];
    }
    return _loading;
}
-(NSMutableArray *)musics{
    if (!_musics) {
        
        FSMusic *music = [[FSMusic alloc] init];
        music.songTitle = @"month";
        music.lastSeconds = 15;
        music.songPic = @"";
        music.songAuthor = @"徐子谦";
        
        
        FSMusic *music1 = [[FSMusic alloc] init];
        music1.songTitle = @"wind";
        music1.lastSeconds = 15;
        music1.songPic = @"";
        music1.songAuthor = @"高超";

        
        FSMusic *music2 = [[FSMusic alloc] init];
        music2.songTitle = @"ugly";
        music2.lastSeconds = 15;
        music2.songPic = @"";
        music2.songAuthor = @"王明";

        _musics = [NSMutableArray arrayWithObjects:music,music1,music2,nil];
        
        
    }
    return _musics;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
     _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    [self.view addSubview:_tableView];
    
    UILabel *tableHeader = [[UILabel alloc] init];
    [tableHeader setText:NSLocalizedString(@"HotMusic", nil)];
    [tableHeader setTextAlignment:(NSTextAlignmentCenter)];
    [tableHeader setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 52)];
    [_tableView setTableHeaderView:tableHeader];
    [_tableView setTableFooterView:[UIView new]];
    
     _sever = [[FSMusicSever alloc] init];
    [_sever setDelegate:self];
    [_sever getMusicList];
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    [_tableView setFrame:self.view.bounds];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.musics count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FSMusicCell *cell = [FSMusicCell musicCellWithTableView:tableView indexPath:indexPath];
    [cell setDelegate:self];
    FSMusic *music = [self.musics objectAtIndex:indexPath.row];
    [cell setMusic:music];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FSMusic *music = [self.musics objectAtIndex:indexPath.row];
    
    if (music.opend) {
        return 147.0;
    }
    return 107.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    FSMusic *music = [self.musics objectAtIndex:indexPath.row];
    
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
            NSInteger index = [self.musics indexOfObject:_music];
            NSIndexPath *IndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            FSMusicCell *preCell = [self.tableView cellForRowAtIndexPath:IndexPath];
            [preCell setIsPlayIng:NO];
        }
        
        [self.view addSubview:self.loading];
        [self.loading loadingViewShow];
        [cell setIsPlayIng:YES];
        
        if (music.songUrl) {
            
            NSString *url = music.songUrl;//[@"http://10.10.32.152:20000/" stringByAppendingString:music.songUrl];
            if (![url hasPrefix:@"http"]) {
                url = [@"http://10.10.32.152:20000/" stringByAppendingString:music.songUrl];
            }
            __weak typeof(self) weakS = self;
            [FSMusicManager downLoadMusic:url complete:^(NSString *localPath, NSError *error) {
                if (!error) {
                    [[FSMusicPlayer sharedPlayer] stop];
                    [[FSMusicPlayer sharedPlayer] setFilePath:localPath];
                }else{
                    return ;
                }
                
                if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
                    [[FSMusicPlayer sharedPlayer] pause];
                }else{
                    [[FSMusicPlayer sharedPlayer] play];
                }
                [weakS.loading loadingViewhide];
            }];
        }else{
            // 测试数据
            if (![_music isEqual:music]) {
                NSString *filePath = [[NSBundle mainBundle] pathForResource:music.songTitle ofType:@"mp3"];
                [[FSMusicPlayer sharedPlayer] stop];
                [[FSMusicPlayer sharedPlayer] setFilePath:filePath];
                
            }
            
            if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
                [[FSMusicPlayer sharedPlayer] pause];
            }else{
                [[FSMusicPlayer sharedPlayer] play];
            }
            
            [self.loading loadingViewhide];
            
        }
    }
    // 更新当前选中的音乐
    _music = music;
}

-(void)tableView:(UITableView *)tableView updateTableWithMusic:(FSMusic *)music selectIndexPath:(NSIndexPath *)indexPath{

    if (![_music isEqual:music]) {
        NSIndexPath *selectedPath = nil;
        if (_music) {
            NSInteger index = [self.musics indexOfObject:_music];
            selectedPath = [NSIndexPath indexPathForRow:index inSection:0];
            _music.opend =  NO;
        }
        music.opend = YES;
        NSMutableArray *paths = [NSMutableArray array];
        if (selectedPath) {
            [paths addObject:selectedPath];
        }
        [paths addObject:indexPath];
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:paths withRowAnimation:(UITableViewRowAnimationFade)];
        [tableView endUpdates];
    }
}

-(void)musicCell:(FSMusicCell *)cell wouldPlay:(FSMusic *)music{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    [self tableView:self.tableView updateTableWithMusic:music selectIndexPath:indexPath];

    [self playMusic:music playViewCell:cell];
}
#pragma mark -
-(void)musicCell:(FSMusicCell *)cell wuoldUseMusic:(FSMusic *)music{
    
    NSString *path = nil;
    if (music.songUrl) {
        NSString *localPath = [FSMusicManager musicPathWithFileName:music.songUrl];
        path = localPath;
        [self updateVideoStreamUrl:localPath];
    }else{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:music.songTitle ofType:@"mp3"];
        path = bundlePath;
        [self updateVideoStreamUrl:bundlePath];
    }

    [[FSMusicPlayer sharedPlayer] stop];
    
    if (_pushed) {
        
        if ([self.delegate respondsToSelector:@selector(musicControllerSelectMusic:)]) {
            [self.delegate musicControllerSelectMusic:path];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
        FSShortVideoRecorderController *recoder = [[FSShortVideoRecorderController alloc] init];
        recoder.musicFilePath = path;
        [self.navigationController pushViewController:recoder animated:YES];
    }
    
    
    [self playMusic:music playViewCell:cell];
}

-(void)updateVideoStreamUrl:(NSString *)filePath{
    //return;
    if (filePath) {
        if (!_timeLine) {
            NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
            NvsVideoResolution videoEditRes;
            videoEditRes.imageWidth = 1200;
            videoEditRes.imageHeight = 720;
            videoEditRes.imagePAR = (NvsRational){1, 1};
            NvsRational videoFps = {25, 1};
            NvsAudioResolution audioEditRes;
            audioEditRes.sampleRate = 48000;
            audioEditRes.channelCount = 2;
            audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
            _timeLine = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes];
        }
        
        int64_t length = _timeLine.duration;
        [_timeLine removeAudioTrack:0];
        NvsAudioTrack *audioTrack = [_timeLine appendAudioTrack];
        [audioTrack appendClip:filePath];
        NvsAudioClip *audio = [audioTrack getClipWithIndex:0];
        [audio changeTrimOutPoint:length affectSibling:YES];
    }
}

#pragma mark -
- (void)musicSeverGetMusics:(NSArray<FSMusic *> *)musics{
    [self.musics addObjectsFromArray:musics];
    [self.tableView reloadData];
}
-(void)musicSeverGetFaild{

}
-(void)dealloc{
    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
