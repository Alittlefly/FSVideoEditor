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
#import "NvsAudioClip.h"
#import "NvsAudioTrack.h"
#import "FSSegmentView.h"

extern int IsArabic;

@interface FSLocalEditorController ()<NvsStreamingContextDelegate,FSThumbnailViewDelegate,FSSegmentViewDelegate>
{
    FSSegmentView *_segmentView;
    int64_t _startTime;
    int64_t _endTime;
    
    UIButton *_backButton;
    UIButton *_finishButton;

}
@property(nonatomic,strong)FSThumbnailView *thumbContent;

@property(nonatomic,strong)NvsLiveWindow *prewidow;
@property(nonatomic,assign)NvsStreamingContext*context;
@property(nonatomic,assign)NvsTimeline   *timeLine;
@property(nonatomic,assign)NvsVideoTrack *videoTrack;
@property(nonatomic,assign)NvsAudioTrack *audioTrack;


@end

@implementation FSLocalEditorController

- (void)creatButtons{
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = IsArabic ? CGRectMake(CGRectGetWidth(self.view.bounds) - 20 - 15, 20, 20,20) : CGRectMake(15, 20, 20, 20);
    [_backButton setImage:[UIImage imageNamed:@"recorder-back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backClik) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    
    _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishButton.frame = IsArabic ? CGRectMake(15, 20, 40, 40) : CGRectMake(CGRectGetWidth(self.view.bounds)- 15 -40, 20, 40, 40);
    [_finishButton setImage:[UIImage imageNamed:@"recorder-finish-red"] forState:UIControlStateNormal];
    [_finishButton addTarget:self action:@selector(saveVideoFile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_finishButton];
}
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
    
    
    _segmentView = [[FSSegmentView alloc] initWithItems:@[NSLocalizedString(@"VerySlow", nil),NSLocalizedString(@"Slow", nil),NSLocalizedString(@"Normal", nil),NSLocalizedString(@"Fast", nil),NSLocalizedString(@"VeryFast", nil)]];
    _segmentView.frame = CGRectMake(32.5, CGRectGetMaxY(_prewidow.frame)+30, CGRectGetWidth(self.view.frame) - 65, 37);
    _segmentView.selectedColor = FSHexRGB(0xFACE15);//[UIColor yellowColor];
    _segmentView.backgroundColor = FSHexRGBAlpha(0x001428, 0.6);[UIColor lightGrayColor];
    _segmentView.selectedTextColor = FSHexRGB(0x1A1D20);//[UIColor redColor];
    _segmentView.unSelectedTextColor = FSHexRGB(0xF5F5F5);
    _segmentView.selectedSegmentIndex = 2;
    _segmentView.layer.cornerRadius = 20;
    _segmentView.layer.masksToBounds = YES;
    _segmentView.delegate = self;
    [self.view addSubview:_segmentView];
    
    [self creatButtons];
}
- (void)backClik{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveVideoFile{

    //
    // tijiao
    //
    NvsVideoClip *videoclip = [_videoTrack getClipWithIndex:0];
    int64_t endTime = _endTime;
    if (endTime == 0) {
        endTime = _timeLine.duration;
    }
    [videoclip changeTrimInPoint:_startTime affectSibling:YES];
    [videoclip changeTrimOutPoint:endTime affectSibling:YES];
    
    NvsAudioClip *audioClip = [_audioTrack getClipWithIndex:0];
    [audioClip changeTrimInPoint:_startTime affectSibling:YES];
    [audioClip changeTrimOutPoint:endTime affectSibling:YES];
    
    FSPublisherController *publish = [[FSPublisherController alloc] init];
    
    publish.filePath = _filePath;
    publish.timeLine = _timeLine;
    publish.trimIn = _startTime;
    publish.trimOut = _endTime;
    
    [self.navigationController pushViewController:publish animated:YES];
    
}
- (void)playVideoFromHead{
    
    if (![_context seekTimeline:_timeLine timestamp:_startTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster]){
        NSLog(@"Failed to seek timeline!");
    }
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Playback){
        int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
        int64_t endTime = _endTime?:_timeLine.duration;
        if(![_context playbackTimeline:_timeLine startTime:startTime endTime:endTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:0]) {
        }
    }
}

- (void)FSSegmentView:(FSSegmentView *)segmentView selected:(NSInteger)index {
    
    NSLog(@"sender: %ld",index); //输出当前的索引值
    NvsClip *clip = [_videoTrack getClipWithIndex:0];
    [clip changeSpeed:index/2.0];
    
    int64_t endTime = _endTime?:_timeLine.duration;
    if (endTime > _timeLine.duration) {
        endTime = _timeLine.duration;
        _endTime = _timeLine.duration;
    }
    
    if(![_context playbackTimeline:_timeLine startTime:_startTime endTime:endTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:0]) {
    }
    
    
    [self initThubnaiView];
}

-(void)reselectTrack{
    
    if (!_timeLine) {
        NSLog(@"Timeline is null!");
        return;
    }
    [_timeLine removeAudioTrack:0];
    [_timeLine removeVideoTrack:0];
    
    _startTime = 0;
    _endTime = 0;
    
    _videoTrack = [_timeLine appendVideoTrack];
    _audioTrack = [_timeLine appendAudioTrack];
    
    NvsVideoClip* clip = [_videoTrack insertClip:_filePath clipIndex:0];
    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
    [clip setVolumeGain:0 rightVolumeGain:0];
    
    [_audioTrack insertClip:_filePath clipIndex:0];

    [self initThubnaiView];
}
-(void)initThubnaiView{
    
    if (_thumbContent) {
        [_thumbContent setDelegate:nil];
        [_thumbContent removeFromSuperview];
         _thumbContent = nil;
    }
    
    if (!_thumbContent) {
        _thumbContent = [[FSThumbnailView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(self.view.bounds) - 70, CGRectGetWidth(self.view.bounds),60) length:15.0 allLength:_timeLine.duration/1000000 minLength:5.0f];
        _thumbContent.delegate = self;
         NvsThumbnailSequenceView *thumbnailSequence = [[NvsThumbnailSequenceView alloc] init];
        _thumbContent.backGroundView = thumbnailSequence;
        thumbnailSequence.stillImageHint = NO;
        thumbnailSequence.mediaFilePath = _filePath;
        thumbnailSequence.startTime = _startTime;
        thumbnailSequence.duration = _timeLine.duration;
        thumbnailSequence.thumbnailAspectRatio = 1.0;
        [self.view addSubview:_thumbContent];
    }

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self reselectTrack];
    
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
    int64_t endTime = _endTime?:_timeLine.duration;
    if(![_context playbackTimeline:timeline startTime:_startTime endTime:endTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:NO flags:0]) {
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
    int64_t endTime = _endTime?:_timeLine.duration;
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
