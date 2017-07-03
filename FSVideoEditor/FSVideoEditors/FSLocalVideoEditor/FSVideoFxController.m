//
//  FSVideoFxController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoFxController.h"
#import "NvsStreamingContext.h"
#import "NvsTimeline.h"
#import "NvsVideoFx.h"
#import "NvsVideoTrack.h"
#import "NvsAudioTrack.h"
#import "NvsAudioClip.h"
#import "NvsVideoClip.h"
#import "NvsTimelineVideoFx.h"
#import "NvsThumbnailSequenceView.h"
#import "FSVideoFxView.h"
#import "FSDissolveAnimator.h"
#import "FSSpringAnimator.h"
#import "FSMusicPlayer.h"

#import "NvsFxDescription.h"

@interface FSVideoFxController ()<NvsStreamingContextDelegate,FSVideoFxViewDelegate,UIViewControllerTransitioningDelegate>
{
    NSMutableString *_videoFxPackageId;
    
    BOOL _needConvert;
    
    CGFloat _startProgress;
}
@property(nonatomic,assign)NvsStreamingContext*context;
@property(nonatomic,assign)NvsVideoTrack *videoTrack;
@end

@implementation FSVideoFxController
- (instancetype)init{
    if (self = [super init]) {
        [self setTransitioningDelegate:self];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self creatSubViews];
    
     _context = [NvsStreamingContext sharedInstance];

    NSString *SoulfxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"C6273A8F-C899-4765-8BFC-E683EE37AA84.videofx"];
    NSString *ScalefxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"A8A4344D-45DA-460F-A18F-C0E2355FE864.videofx"];
    
    [_context.assetPackageManager installAssetPackage:SoulfxPath license:nil type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:nil];
    [_context.assetPackageManager installAssetPackage:ScalefxPath license:nil type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:nil];
    
     _prewidow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds) - 210)/2.0, 54, 210, CGRectGetHeight(self.view.bounds) - 228 - 54 - 12)];
    [self.view addSubview:_prewidow];

     _controlView = [[FSControlView alloc] initWithFrame:_prewidow.frame];
    UITapGestureRecognizer *tapGesturs = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controlVideo)];
    [_controlView addGestureRecognizer:tapGesturs];
    [self.view addSubview:_controlView];

    NSArray *fxs = [_context.assetPackageManager getAssetPackageListOfType:(NvsAssetPackageType_VideoFx)];

    if (!_timeLine) {
        return;
    }
    
    _videoFxView = [[FSVideoFxView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 228, CGRectGetWidth(self.view.bounds),228) fxs:fxs];
    [_videoFxView setDelegate:self];
    [self.view addSubview:_videoFxView];
    _videoFxView.duration = _timeLine.duration/1000000.0;
    
     _videoTrack = [_timeLine getVideoTrackByIndex:0];
    
    
    NvsThumbnailSequenceView *thumbnailSequence = [[NvsThumbnailSequenceView alloc] init];
    thumbnailSequence.stillImageHint = NO;
    thumbnailSequence.mediaFilePath = _filePath;
    thumbnailSequence.startTime = 0;
    thumbnailSequence.duration = _timeLine.duration;
    thumbnailSequence.thumbnailAspectRatio = 1.0;
    [thumbnailSequence setFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.bounds), 27)];
    [thumbnailSequence setClipsToBounds:NO];
    _videoFxView.progressBackView = thumbnailSequence;
    
    [[FSMusicPlayer sharedPlayer] setFilePath:_musicUrl];

}
-(void)controlVideo{
    if ([_context getStreamingEngineState] != NvsStreamingEngineState_Playback) {
        [self playVideoFromHead];
    }else{
        [self stopVideoForCrrentTime];
        
    }
}

-(void)stopVideoForCrrentTime{
    [_videoFxView stop];
    [[FSMusicPlayer sharedPlayer] stop];
    [_controlView setState:NO];
    int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
    [_context seekTimeline:_timeLine timestamp:startTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster];
}

-(void)playVideoFromHead{
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Playback){
        int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
        if(![_context playbackTimeline:_timeLine startTime:startTime endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:NO flags:0]) {
        }
        
        [_videoFxView start];
        [_controlView setState:YES];
        [[FSMusicPlayer sharedPlayer] playAtTime:startTime/1000000.0+_musicAttime];
        [[FSMusicPlayer sharedPlayer] play];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_context setDelegate:self];
    
    NvsAudioTrack *audiotrack = [_timeLine getAudioTrackByIndex:0];
    [audiotrack setVolumeGain:_musicUrl?0:1 rightVolumeGain:_musicUrl?0:1];
    
    if (![_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster]){
        NSLog(@"Failed to seek timeline!");
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_videoFxView stop];
    [[FSMusicPlayer sharedPlayer] stop];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [_context connectTimeline:_timeLine withLiveWindow:_prewidow];

    [_context setDelegate:self];
    
    if (![_context seekTimeline:_timeLine timestamp:[_context getTimelineCurrentPosition:_timeLine] videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster]){
        NSLog(@"Failed to seek timeline!");
    }
}

- (void)creatSubViews{
    UIButton *cancle = [[UIButton alloc] init];
    [cancle addTarget:self action:@selector(cancle) forControlEvents:(UIControlEventTouchUpInside)];
    [cancle setTitle:@"cancle" forState:(UIControlStateNormal)];
    [cancle sizeToFit];
    [cancle setFrame:CGRectMake(20, 20, 100, 24)];
    [self.view addSubview:cancle];
    
    UIButton *save = [[UIButton alloc] init];
    [save addTarget:self action:@selector(save) forControlEvents:(UIControlEventTouchUpInside)];
    [save setTitle:@"save" forState:(UIControlStateNormal)];
    [save sizeToFit];
    [save setFrame:CGRectMake(270, 20, 100, 24)];
    [self.view addSubview:save];
}
- (void)cancle{
    NvsTimelineVideoFx *lastVideoFx =  [_timeLine getLastTimelineVideoFx];
    while (lastVideoFx) {
        [_timeLine removeTimelineVideoFx:lastVideoFx];
        lastVideoFx = [_timeLine getLastTimelineVideoFx];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)save{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma make -
-(void)didPlaybackEOF:(NvsTimeline *)timeline{
    if (![_context seekTimeline:timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster]){
        NSLog(@"Failed to seek timeline!");
    }
    [[FSMusicPlayer sharedPlayer] stop];

    [self playVideoFromHead];
}
-(void)didPlaybackStopped:(NvsTimeline *)timeline{
    
    [_controlView setState:NO];
    [_videoFxView stop];
    [[FSMusicPlayer sharedPlayer] stop];
}
#pragma mark -
-(void)videoFxSelectProgress:(FSVideoFxView *)videoFxView progress:(CGFloat)progress packageFxId:(NSString *)fxId{

    if (fxId != nil) {
        _startProgress = progress;
        int64_t startPoint = _timeLine.duration * progress;
        [_timeLine addPackagedTimelineVideoFx:startPoint duration:_timeLine.duration videoFxPackageId:fxId];
        [_context seekTimeline:_timeLine timestamp:startPoint videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
        [_context playbackTimeline:_timeLine startTime:startPoint endTime:_timeLine.duration videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) preload:YES flags:0];
        [_controlView setState:YES];
        [[FSMusicPlayer sharedPlayer] playAtTime:startPoint/1000000.0 + _musicAttime];
        [[FSMusicPlayer sharedPlayer] play];
    }else{
        int64_t point = _timeLine.duration * progress;
        [_context seekTimeline:_timeLine timestamp:point videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
        [_controlView setState:NO];
        [[FSMusicPlayer sharedPlayer] stop];

    }
    

}
-(void)videoFxSelectEnd:(FSVideoFxView *)videoFxView progress:(CGFloat)progress packageFxId:(NSString *)fxId{
    int64_t startPoint = _timeLine.duration * _startProgress;
    int64_t endPoint = _timeLine.duration * progress;
    
    NvsTimelineVideoFx *timeLineFx = [_timeLine getLastTimelineVideoFx];
    [timeLineFx changeInPoint:startPoint];
    [timeLineFx changeOutPoint:endPoint];
    
    [_context seekTimeline:_timeLine timestamp:endPoint videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
    
    [_controlView setState:NO];
    [[FSMusicPlayer sharedPlayer] stop];
    [videoFxView showUndoButton];
}
-(void)videoFxViewSelectTimeFx:(FSVideoFxView *)videoFxView type:(FSVideoFxType)type duration:(int64_t)duration progress:(CGFloat)progress{
    if (type == FSVideoFxTypeSlow) {
        //缓慢
        int64_t point = _timeLine.duration * progress;
        
        NvsVideoClip *orginalClip = [_videoTrack getClipWithTimelinePosition:point];
        BOOL splited = [_videoTrack splitClip:orginalClip.index splitPoint:(point - duration/2.0)];
        if (splited) {
            NvsVideoClip *dealClip = [_videoTrack getClipWithTimelinePosition:point];
            splited = [_videoTrack splitClip:dealClip.index splitPoint:(point + duration/2.0)];
        }
        
        if (splited) {
            NvsVideoClip *videoClip = [_videoTrack getClipWithTimelinePosition:point];
            [videoClip changeSpeed:0.5];
        }
        
    }else if(type == FSVideoFxTypeRepeat){
        // 重复
        int64_t point = _timeLine.duration * progress;
        
        NvsVideoClip *clip = [_videoTrack getClipWithIndex:0];

    
        [_videoTrack addClip:_filePath inPoint:point trimIn:(point - duration/2.0) trimOut:(point + duration/2.0)];
        [_videoTrack addClip:_filePath inPoint:point trimIn:(point - duration/2.0) trimOut:(point + duration/2.0)];
        [_videoTrack addClip:_filePath inPoint:point trimIn:(point - duration/2.0) trimOut:(point + duration/2.0)];
    }else if (type == FSVideoFxTypeRevert){
        // 倒序播放
        
    }
    videoFxView.duration = _timeLine.duration;
}
-(void)videoFxUndoPackageFx:(FSVideoFxView *)videoFxView{
    NvsTimelineVideoFx *timeLineFx = [_timeLine getLastTimelineVideoFx];
    if (timeLineFx) {
        
        [_timeLine removeTimelineVideoFx:timeLineFx];
        
        if (![_timeLine getLastTimelineVideoFx]) {
            [videoFxView hideUndoButton];
        }
    }
}


-(CGFloat)videoFxViewUpdateProgress:(FSVideoFxView *)videoFxView{
    int64_t current = [_context getTimelineCurrentPosition:_timeLine];
    CGFloat progress = (CGFloat)current/_timeLine.duration;
    
    NSLog(@"current %lld",current);
    
    return progress;
}

#pragma mark - 
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [FSDissolveAnimator initWithSourceVc:source];
}
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [FSSpringAnimator initWithSourceVc:dismissed];
}

-(void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

@end
