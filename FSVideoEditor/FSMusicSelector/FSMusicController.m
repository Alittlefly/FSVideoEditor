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
#import "FSMusicCell.h"
#import "FSMusicPlayer.h"

@interface FSMusicController ()<UITableViewDelegate,UITableViewDataSource,FSMusicCellDelegate>{
    FSMusic *_music;
}
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *musics;

@end

@implementation FSMusicController
-(NSArray *)musics{
    if (!_musics) {
        
        FSMusic *music = [[FSMusic alloc] init];
        music.name = @"month";
        music.time = 15;
        music.pic = @"";
        music.author = @"徐子谦";
        
        
        FSMusic *music1 = [[FSMusic alloc] init];
        music1.name = @"wind";
        music1.time = 15;
        music1.pic = @"";
        music1.author = @"高超";

        
        FSMusic *music2 = [[FSMusic alloc] init];
        music2.name = @"ugly";
        music2.time = 15;
        music2.pic = @"";
        music2.author = @"王明";

        _musics = [NSArray arrayWithObjects:music,music1,music2,nil];
        
        
    }
    return _musics;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Do any additional setup after loading the view.
     _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    [self.view addSubview:_tableView];
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
        return 147;
    }
    
    return 107;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FSMusic *music = [self.musics objectAtIndex:indexPath.row];
    
    if (![_music isEqual:music]) {
        NSIndexPath *preIndexPath = nil;
        if (_music != nil) {
            
            [_music setIsPlaying:NO];
            [_music setOpend:NO];
            
            NSInteger index = [self.musics indexOfObject:_music];
            preIndexPath = [NSIndexPath indexPathWithIndex:index];
        }
        music.opend = YES;
       [tableView reloadData];
    }
    
    [self musicCell:[tableView cellForRowAtIndexPath:indexPath] wouldPlay:music];
    
    _music = music;

}

#pragma mark -
-(void)musicCell:(FSMusicCell *)cell wuoldUseMusic:(FSMusic *)music{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:music.name ofType:@"mp3"];
    
    if (bundlePath) {
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
        [audioTrack appendClip:bundlePath];
        NvsAudioClip *audio = [audioTrack getClipWithIndex:0];
        [audio changeTrimOutPoint:length affectSibling:YES];
    }
    
    if (_pushed) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        FSShortVideoRecorderController *recoder = [[FSShortVideoRecorderController alloc] init];
        recoder.musicFilePath = bundlePath;
        [self.navigationController pushViewController:recoder animated:YES];
    }
    
    [[FSMusicPlayer sharedPlayer] stop];
}

-(void)musicCell:(FSMusicCell *)cell wouldPlay:(FSMusic *)music{
    
    if (![_music isEqual:music]) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:_music.name ofType:@"mp3"];
        [[FSMusicPlayer sharedPlayer] stop];
        [[FSMusicPlayer sharedPlayer] setFilePath:filePath];
    }

    if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
        [[FSMusicPlayer sharedPlayer] pause];
        music.isPlaying = NO;
    }else{
        [[FSMusicPlayer sharedPlayer] play];
        music.isPlaying = YES;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
