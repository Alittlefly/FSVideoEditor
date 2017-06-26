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
#import "FSPublisherController.h"
#import "FSThumbnailView.h"


@interface FSLocalEditorController ()<NvsStreamingContextDelegate,FSThumbnailViewDelegate>
{
    UISegmentedControl *_speedSegment;
    int64_t _startTime;
    int64_t _endTime;
}
@property(nonatomic,strong)FSThumbnailView *thumbContent;

@property(nonatomic,strong)NvsThumbnailSequenceView *thumbnailSequence;
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
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
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
    
    _startTime = 0;
    _endTime = 0;
    
    if (!_timeLine) {
        NSLog(@"Timeline is null!");
        return;
    }
    _videoTrack = [_timeLine appendVideoTrack];
    if (!_videoTrack) {
        NSLog(@"Video track is null!");
        return;
    }

    
    if (!_filePath) {
        return;
    }

    NvsVideoClip* clip = [_videoTrack insertClip:_filePath clipIndex:0];
    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
    
    if (!_thumbnailSequence) {
        _thumbnailSequence = [[NvsThumbnailSequenceView alloc] init];
        _thumbContent = [[FSThumbnailView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(self.view.bounds) - 70, CGRectGetWidth(self.view.bounds),60) length:15.0 allLength:_timeLine.duration/1000000 minLength:3.0f];
        _thumbContent.delegate = self;
        _thumbContent.backGroundView = _thumbnailSequence;
        [self.view addSubview:_thumbContent];
        
    }
     self.thumbnailSequence.stillImageHint = NO;
     self.thumbnailSequence.mediaFilePath = _filePath;
     self.thumbnailSequence.startTime = _startTime;
     self.thumbnailSequence.duration = _timeLine.duration;
     self.thumbnailSequence.thumbnailAspectRatio = 1.0;
    
    
    _speedSegment = [[UISegmentedControl alloc] initWithItems:@[@"极慢",@"慢",@"标准",@"快",@"极快"]];
    _speedSegment.frame = CGRectMake(32.5, CGRectGetMaxY(_prewidow.frame)+76, CGRectGetWidth(self.view.frame) - 65, 37);
    _speedSegment.selectedSegmentIndex = 2;
    _speedSegment.backgroundColor = [UIColor lightGrayColor];
    _speedSegment.tintColor = [UIColor yellowColor];
    _speedSegment.layer.cornerRadius = 20;
    _speedSegment.layer.masksToBounds = YES;
    [_speedSegment addTarget:self action:@selector(selectPlaySpeed:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_speedSegment];
    
    self.navigationItem.rightBarButtonItem = [self rightBarbuttonItem];
}
- (UIBarButtonItem *)rightBarbuttonItem{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"save" style:(UIBarButtonItemStyleDone) target:self action:@selector(saveVideoFile)];
    return item;
}
- (void)saveVideoFile{

    //
    // tijiao
    //
    
    NvsVideoClip *clip = [_videoTrack getClipWithIndex:0];
    [clip changeTrimInPoint:_startTime affectSibling:YES];
    int64_t endTime = _endTime;
    if (endTime == 0) {
        endTime = _timeLine.duration;
    }
    [clip changeTrimOutPoint:endTime affectSibling:YES];
    
    FSPublisherController *publish = [[FSPublisherController alloc] init];
    publish.filePath = _filePath;
    publish.timeLine = _timeLine;
    [self.navigationController pushViewController:publish animated:YES];
    
}
- (void)playVideoFromHead{
    
    if (![_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster]){
        NSLog(@"Failed to seek timeline!");
    }
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Playback){
        int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
        if(![_context playbackTimeline:_timeLine startTime:startTime endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:0]) {
        }
    }
}

- (void)selectPlaySpeed:(UISegmentedControl *)sender {
    NSLog(@"sender: %ld",sender.selectedSegmentIndex); //输出当前的索引值
    NvsClip *clip = [_videoTrack getClipWithIndex:0];
    [clip changeSpeed:sender.selectedSegmentIndex/2.0];
    if(![_context playbackTimeline:_timeLine startTime:0 endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:0]) {
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_context setDelegate:self];
    // 将timeline连接到NvsLiveWindow控件
    [_context connectTimeline:_timeLine withLiveWindow:_prewidow];

    [self playVideoFromHead];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if ([_context getStreamingEngineState] != NvsStreamingEngineState_Stopped) {
        [_context stop];
    }
    [_context setDelegate:nil];
}

#pragma mark -
-(void)didPlaybackStopped:(NvsTimeline *)timeline{

    NSLog(@"didPlaybackStopped");
}
- (void)didPlaybackEOF:(NvsTimeline *)timeline{
    if(![_context playbackTimeline:timeline startTime:0 endTime:timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:NO flags:0]) {
    }
}

// 生成进度的回调函数
- (void)didCompileProgress:(NvsTimeline *)timeline progress:(int)progress {
    NSLog(@"Compile timeline progress: %d", progress);
}

#pragma mark -
-(void)thumbnailViewSelectValue:(double)value type:(SliderType)type{
    if (type == SliderTypeLeftSlider) {
        // startValue
         _startTime = value * 1000000.0;
        [_context seekTimeline:_timeLine timestamp:_startTime videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
    }else if(type == SliderTypeRightSlider){
         _endTime = value * 1000000.0;
        [_context seekTimeline:_timeLine timestamp:_endTime videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
    }
}
-(void)thumbnailViewSelectStartValue:(double)startValue endValue:(double)endvalue{
     _startTime = startValue * 1000000.0;
     _endTime = endvalue * 1000000.0;
    [_context seekTimeline:_timeLine timestamp:_startTime videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
}
-(void)thumbnailViewEndSelect{
    int64_t endTime = 0;
    if (_endTime == 0) {
        endTime = _timeLine.duration;
    }else{
        endTime = _endTime;
    }
    [_context playbackTimeline:_timeLine startTime:_startTime endTime:endTime videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) preload:YES flags:0];
}
-(void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
