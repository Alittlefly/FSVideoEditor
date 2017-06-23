//
//  FSLocalEditorController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/22.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSLocalEditorController.h"
#import "NvsThumbnailSequenceView.h"
#import "NvsStreamingContext.h"
#import "NvsVideoClip.h"
#import "NvsVideoTrack.h"

@interface FSLocalEditorController ()<NvsStreamingContextDelegate>
{
    UISegmentedControl *_speedSegment;
}
@property(nonatomic,strong)NvsThumbnailSequenceView *thumbnailSequence;
@property(nonatomic,strong)UIScrollView *thumbContent;

@property(nonatomic,strong)NvsLiveWindow *prewidow;
@property(nonatomic,assign)NvsStreamingContext*context;
@property(nonatomic,assign)NvsTimeline   *timeLine;
@property(nonatomic,assign)NvsVideoTrack *videoTrack;

@end

@implementation FSLocalEditorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _prewidow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(self.view.bounds)/2.0 - 210/2.0, CGRectGetWidth(self.view.bounds), 210)];
    [self.view addSubview:_prewidow];
    _context = [NvsStreamingContext sharedInstance];
    if(!_context){
        return;
    }
    
    [_context setDelegate:self];
//
    // 初始化timeline
    NvsVideoResolution videoEditRes;
    videoEditRes.imageWidth = 1200;//CGRectGetWidth(self.view.bounds);
    videoEditRes.imageHeight = 720;// CGRectGetHeight(self.view.bounds);
    videoEditRes.imagePAR = (NvsRational){1, 1};
    NvsRational videoFps = {25, 1};
    NvsAudioResolution audioEditRes;
    audioEditRes.sampleRate = 48000;
    audioEditRes.channelCount = 2;
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
    
    _timeLine = [_context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes];
    if (!_timeLine) {
        NSLog(@"Timeline is null!");
        return;
    }
    
    
    _videoTrack = [_timeLine appendVideoTrack];
    if (!_videoTrack) {
        NSLog(@"Video track is null!");
        return;
    }
    
    // 将timeline连接到NvsLiveWindow控件
    if (![_context connectTimeline:_timeLine withLiveWindow:_prewidow]) {
        NSLog(@"Failed to connect timeline to liveWindow!");
        return;
    }
    
    if (!_filePath) {
        return;
    }
    
    if (!_thumbnailSequence) {
        _thumbnailSequence = [[NvsThumbnailSequenceView alloc] init];
        _thumbContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(self.view.bounds) - 70, CGRectGetWidth(self.view.bounds),60)];
        [_thumbContent setBackgroundColor:[UIColor redColor]];
        [_thumbContent addSubview:_thumbnailSequence];
        [_thumbContent setContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 0)];
        [self.view addSubview:_thumbContent];

    }

    NvsVideoClip* clip = [_videoTrack insertClip:_filePath clipIndex:0];
    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
    
     self.thumbnailSequence.stillImageHint = NO;
     self.thumbnailSequence.mediaFilePath = _filePath;
     self.thumbnailSequence.startTime = 0;
     self.thumbnailSequence.duration = _timeLine.duration;
     self.thumbnailSequence.thumbnailAspectRatio = 1.0;
    [self.thumbnailSequence setFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.bounds), 60)];
    [self.thumbnailSequence setClipsToBounds:NO];
    
    
    if (![_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster]){
        NSLog(@"Failed to seek timeline!");
    }
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Playback){
        int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
        if(![_context playbackTimeline:_timeLine startTime:startTime endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:NO flags:0]) {
        }
    }
    
    
    _speedSegment = [[UISegmentedControl alloc] initWithItems:@[@"极慢",@"慢",@"标准",@"快",@"极快"]];
    _speedSegment.frame = CGRectMake(32.5, CGRectGetMinY(_prewidow.frame)+76, CGRectGetWidth(self.view.frame) - 65, 37);
    _speedSegment.selectedSegmentIndex = 2;
    _speedSegment.backgroundColor = [UIColor lightGrayColor];
    _speedSegment.tintColor = [UIColor yellowColor];
    _speedSegment.layer.cornerRadius = 20;
    _speedSegment.layer.masksToBounds = YES;
    [_speedSegment addTarget:self action:@selector(selectPlaySpeed:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_speedSegment];
}
- (void)selectPlaySpeed:(UISegmentedControl *)sender {
    NSLog(@"sender: %ld",sender.selectedSegmentIndex); //输出当前的索引值
    //_playSpeed = sender.selectedSegmentIndex;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if ([_context getStreamingEngineState] != NvsStreamingEngineState_Stopped) {
        [_context stop];
    }
    [_context setDelegate:nil];
}

#pragma mark -

- (void)didPlaybackEOF:(NvsTimeline *)timeline{
    if(![_context playbackTimeline:timeline startTime:0 endTime:timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:NO flags:0]) {
    }
}

-(void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
