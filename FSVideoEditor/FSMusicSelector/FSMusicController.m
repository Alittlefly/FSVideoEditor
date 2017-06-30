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

@interface FSMusicController ()<UITableViewDelegate,UITableViewDataSource>
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
    
    static NSString *cellid = @"asdasd";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];//[tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellid];
    }
    [cell.textLabel setText:[self.musics objectAtIndex:indexPath.row]];
    return cell;
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

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
