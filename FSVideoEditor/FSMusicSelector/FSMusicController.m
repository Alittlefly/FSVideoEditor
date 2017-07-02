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
    NSString *_music;
}
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *musics;

@end

@implementation FSMusicController
-(NSArray *)musics{
    if (!_musics) {
        _musics = [NSArray arrayWithObjects:@"month",@"wind",@"ugly",nil];
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
    [cell setMusic:[self.musics objectAtIndex:indexPath.row]];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 107;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:[self.musics objectAtIndex:indexPath.row] ofType:@"mp3"];
    
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
        [self.navigationController pushViewController:recoder animated:YES];
    }
    
    [[FSMusicPlayer sharedPlayer] stop];
}

-(void)musicCell:(FSMusicCell *)cell wouldPlay:(NSString *)music{
    
    if (![_music isEqualToString:music]) {
        _music = music;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:_music ofType:@"mp3"];
        
        [[FSMusicPlayer sharedPlayer] stop];
        [[FSMusicPlayer sharedPlayer] setFilePath:filePath];
    }
    
    if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
        [[FSMusicPlayer sharedPlayer] pause];
    }else{
        [[FSMusicPlayer sharedPlayer] play];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
