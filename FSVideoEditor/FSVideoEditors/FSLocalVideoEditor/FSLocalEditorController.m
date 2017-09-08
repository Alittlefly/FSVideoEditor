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
#import "FSEditorLoading.h"
#import "FSShortVideoRecorderManager.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"
#import "FSDraftManager.h"
#import "FSAlertView.h"

@interface FSLocalEditorController ()<NvsStreamingContextDelegate,FSThumbnailViewDelegate,FSSegmentViewDelegate,FSShortVideoRecorderManagerDelegate>
{
    FSSegmentView *_segmentView;
    int64_t _startTime;
    int64_t _endTime;
    
    int64_t _originalStartTime;
    int64_t _originalEndTime;
    
    int64_t _originalDuration;
    int64_t _maxDurationLength;
    
    UIButton *_backButton;
    UIButton *_finishButton;
    
    NSString *_outPutFilePath;
    NSString *_convertOutPutFilePath;
    
    FSDraftInfo *_draftInfo;
    
    NSInteger _currentSpeedIndex;

}
@property(nonatomic,strong)FSThumbnailView *thumbContent;

@property(nonatomic,strong)NvsLiveWindow *prewidow;
@property(nonatomic,assign)NvsStreamingContext*context;
@property(nonatomic,assign)NvsTimeline   *timeLine;
@property(nonatomic,assign)NvsVideoTrack *videoTrack;
@property(nonatomic,assign)NvsAudioTrack *audioTrack;
@property(nonatomic,strong)FSEditorLoading *loading;


@end

@implementation FSLocalEditorController
-(FSEditorLoading *)loading{
    if(!_loading){
        _loading = [[FSEditorLoading alloc] initWithFrame:self.view.bounds];
    }
    return _loading;
}
- (void)creatButtons{
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(CGRectGetWidth(self.view.bounds) - 20 - 15, 20, 20,20) : CGRectMake(15, 20, 20, 20);
    [_backButton setImage:[UIImage imageNamed:@"recorder-back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backClik) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    
    _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishButton.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(15, 20, 40, 40) : CGRectMake(CGRectGetWidth(self.view.bounds)- 15 -40, 20, 40, 40);
    [_finishButton setImage:[UIImage imageNamed:@"recorder-finish-red"] forState:UIControlStateNormal];
    [_finishButton addTarget:self action:@selector(saveVideoFile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_finishButton];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor blackColor]];
//    
//    _prewidow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(self.view.bounds)/2.0 - 210/2.0, CGRectGetWidth(self.view.bounds), 210)];
    _prewidow = [[NvsLiveWindow alloc] initWithFrame:self.view.bounds];
    _prewidow.fillMode = NvsLiveWindowFillModePreserveAspectCrop;
    [self.view addSubview:_prewidow];
    
    
    NSString *verifySdkLicenseFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"198-14-0f022a4d5bfa12d379d469e146c1e9bf.lic"];
    
    [NvsStreamingContext verifySdkLicenseFile:verifySdkLicenseFilePath];
    _context = [NvsStreamingContext sharedInstanceWithFlags:(NvsStreamingContextFlag_Support4KEdit)];
    _draftInfo = [FSDraftManager sharedManager].tempInfo;
    
    if (!_draftInfo) {
        _draftInfo = [[FSDraftManager sharedManager] draftInfoWithPreInfo:nil];
    }
    
    if(!_context){
        return;
    }
    
    [_context setDelegate:self];
    
    // 初始化timeline
    NvsVideoResolution videoEditRes;
    videoEditRes.imageWidth = 540;
    videoEditRes.imageHeight = 960;
    videoEditRes.imagePAR = (NvsRational){1, 1};
    NvsRational videoFps = {25, 1};
    NvsAudioResolution audioEditRes;
    audioEditRes.sampleRate = 48000;
    audioEditRes.channelCount = 2;
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
    _timeLine = [_context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes];
    
    
    _segmentView = [[FSSegmentView alloc] initWithItems:@[[FSShortLanguage CustomLocalizedStringFromTable:@"VerySlow"],[FSShortLanguage CustomLocalizedStringFromTable:@"Slow"],[FSShortLanguage CustomLocalizedStringFromTable:@"Normal"],[FSShortLanguage CustomLocalizedStringFromTable:@"Fast"],[FSShortLanguage CustomLocalizedStringFromTable:@"VeryFast"]]];
    _segmentView.frame = CGRectMake(32.5, CGRectGetHeight(self.view.bounds)/2.0 + 210/2.0+30, CGRectGetWidth(self.view.frame) - 65, 37);
    _segmentView.selectedColor = FSHexRGB(0xFACE15);//[UIColor yellowColor];
    _segmentView.backgroundColor = FSHexRGBAlpha(0x001428, 0.6);[UIColor lightGrayColor];
    _segmentView.selectedTextColor = FSHexRGB(0x1A1D20);//[UIColor redColor];
    _segmentView.unSelectedTextColor = FSHexRGB(0xF5F5F5);
    _segmentView.selectedSegmentIndex = 2;
    _segmentView.layer.cornerRadius = 5;
    _segmentView.layer.masksToBounds = YES;
    _segmentView.delegate = self;
    _currentSpeedIndex = _segmentView.selectedSegmentIndex;
    [self.view addSubview:_segmentView];
    
    [self creatButtons];
    
    _maxDurationLength = 15000000.0;
}

- (void)backClik{
    [[FSDraftManager sharedManager] clearInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveVideoFile{
    
    NvsVideoClip *videoclip = [_videoTrack getClipWithIndex:0];
    int64_t startTime = _originalStartTime;
    int64_t endTime = _originalEndTime;
    
    if (endTime - startTime > _maxDurationLength) {
        endTime = startTime + _maxDurationLength;
    }
    
    [videoclip changeTrimInPoint:startTime affectSibling:YES];
    [videoclip changeTrimOutPoint:endTime affectSibling:YES];
    
    NvsAudioClip *audioClip = [_audioTrack getClipWithIndex:0];
    [audioClip changeTrimInPoint:startTime affectSibling:YES];
    [audioClip changeTrimOutPoint:endTime affectSibling:YES];

    [self.view addSubview:self.loading];
    [self.loading loadingViewShow];
    
     _outPutFilePath = [self getCompilePath];
   BOOL success = [_context compileTimeline:_timeLine startTime:0 endTime:_timeLine.duration outputFilePath:_outPutFilePath videoResolutionGrade:(NvsCompileVideoResolutionGradeCustom) videoBitrateGrade:(NvsCompileBitrateGradeHigh) flags:0];
    if (!success) {
        [self.loading loadingViewhide];
    }
}

- (NSString *)getCompilePath {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString * timeRandom = [formatter stringFromDate:[NSDate date]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *final = [documentsDirectory stringByAppendingPathComponent:@"tmp"];
    return [final stringByAppendingFormat:@"/video%@.mov",timeRandom];
}

- (void)showInPublic{

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


    CGFloat vSpeed = 1.0;
    switch (index) {
        case 0:
            vSpeed = 1.0/3.0;
            break;
        case 1:
            vSpeed = 0.5;
            break;
        case 2:
            vSpeed = 1.0;
            break;
        case 3:
            vSpeed = 2.0;
            break;
        case 4:
            vSpeed = 3.0;
            break;
        default:
            break;
    }
    int64_t Originalduration = _timeLine.duration * _draftInfo.vSpeed;
    int64_t willBeduration = Originalduration/vSpeed;
    if (willBeduration < 5000000.0) {
        FSAlertView *alert = [[FSAlertView alloc] init];
        [alert showWithMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"leastTime"]];
        [segmentView setSelectedSegmentIndex:_currentSpeedIndex];
        return;
    }
    if (_currentSpeedIndex == index) {
        return;
    }
    _currentSpeedIndex = index;
    
    NvsClip *clip = [_videoTrack getClipWithIndex:0];
    [clip changeSpeed:vSpeed];
    
    _draftInfo.vSpeed = vSpeed;
    _startTime = _originalStartTime / vSpeed;
    _endTime = _originalEndTime / vSpeed;
    
    _maxDurationLength = MIN(_originalDuration / vSpeed, 15000000.0 /vSpeed);
    
    if(![_context playbackTimeline:_timeLine startTime:_startTime endTime:_endTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:0]) {
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
    
    _videoTrack = [_timeLine appendVideoTrack];
    _audioTrack = [_timeLine appendAudioTrack];
    
    NvsVideoClip* clip = [_videoTrack insertClip:_filePath clipIndex:0];
    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
    [clip setVolumeGain:0 rightVolumeGain:0];
    [clip changeTrimInPoint:0 affectSibling:YES];
    [clip changeTrimOutPoint:_timeLine.duration affectSibling:YES];
    [_audioTrack insertClip:_filePath clipIndex:0];
    
    _startTime = 0.0;
    _endTime  = _timeLine.duration;
    
    _originalStartTime = 0.0;
    _originalEndTime = _timeLine.duration;
    _originalDuration = _timeLine.duration;
    _maxDurationLength = MIN(_timeLine.duration, 15000000.0);
    [self initThubnaiView];
}
-(void)initThubnaiView{
    
    if (_thumbContent) {
        [_thumbContent setDelegate:nil];
        [_thumbContent removeFromSuperview];
         _thumbContent = nil;
    }
    
    if (!_thumbContent) {
        _thumbContent = [[FSThumbnailView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(self.view.bounds) - 70, CGRectGetWidth(self.view.bounds),60) length:15.0 allLength:(CGFloat)(_timeLine.duration/1000000.0) minLength:5.0f];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFromHead) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];


    [self.navigationController setNavigationBarHidden:YES];

    [self reselectTrack];
    
    [_context setDelegate:self];
    // 将timeline连接到NvsLiveWindow控件
    [_context connectTimeline:_timeLine withLiveWindow:_prewidow];

    [self playVideoFromHead];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

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

-(void)didCompileFailed:(NvsTimeline *)timeline{
    [self.loading loadingViewhide];
}
-(void)didCompileFinished:(NvsTimeline *)timeline{
    
    _draftInfo.vOriginalPath = _outPutFilePath;

    [[FSShortVideoRecorderManager sharedInstance] setDelegate:self];
    [[FSShortVideoRecorderManager sharedInstance] beginConvertReverse:_outPutFilePath];
}

#pragma mark - 

- (void)FSShortVideoRecorderManagerConvertorFinished:(NSString *)filePath{
    
    
    [self.loading loadingViewhide];
    
    FSPublisherController *publish = [[FSPublisherController alloc] init];
    _draftInfo.vType = FSDraftInfoTypeVideo;
    _draftInfo.vFinalPath = _outPutFilePath;
    _draftInfo.vConvertPath = filePath;
    
    publish.draftInfo = _draftInfo;
    publish.timeLine = _timeLine;
    
    [[FSDraftManager sharedManager] mergeInfo];
    [[FSDraftManager sharedManager] clearInfo];
    
    [self.navigationController pushViewController:publish animated:YES];
}
- (void)FSShortVideoRecorderManagerConvertorFaild{
    [self.loading loadingViewhide];
}

#pragma mark -
-(void)thumbnailViewSelectValue:(double)value type:(SliderType)type{
    if (type == SliderTypeLeftSlider) {
        // startValue
         _originalStartTime = value * 1000000.0 / _draftInfo.vSpeed;
         _startTime = value * 1000000.0 ;
        [_context seekTimeline:_timeLine timestamp:_startTime videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
    }else if(type == SliderTypeRightSlider){
         _originalEndTime = value * 1000000.0 / _draftInfo.vSpeed;
         _endTime = value * 1000000.0;
        [_context seekTimeline:_timeLine timestamp:_endTime videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
    }
}
-(void)thumbnailViewSelectStartValue:(double)startValue endValue:(double)endvalue{
     _startTime = startValue * 1000000.0;
     _endTime = endvalue * 1000000.0;
    _originalStartTime = startValue * 1000000.0 / _draftInfo.vSpeed;
    _originalEndTime = endvalue * 1000000.0 / _draftInfo.vSpeed;
    [_context seekTimeline:_timeLine timestamp:_startTime videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
}
-(void)thumbnailViewEndSelect{
    [_context playbackTimeline:_timeLine startTime:_startTime endTime:_endTime videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) preload:YES flags:0];
}
-(void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
