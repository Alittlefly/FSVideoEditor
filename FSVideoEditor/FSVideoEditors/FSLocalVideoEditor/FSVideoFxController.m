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
#import "FSVideoEditorCommenData.h"

#import "NvsFxDescription.h"
#import "FSShortLanguage.h"

@interface FSVideoFxController ()<NvsStreamingContextDelegate,FSVideoFxViewDelegate,UIViewControllerTransitioningDelegate>
{
    NSMutableString *_videoFxPackageId;
    
    CGFloat _startProgress;
    
    FSVideoFxOperationStack *_tempFxStack;
    
    
    FSVideoFxType _selectType;
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
    
     _tempFxStack = [FSVideoFxOperationStack new];
    [_tempFxStack pushVideoFxWithFxManager:_fxOperationStack];
    
    [self creatSubViews];
    NSString *verifySdkLicenseFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"198-14-4532bd69c375c2bc29936aa8c5af104a.lic"];
    
    [NvsStreamingContext verifySdkLicenseFile:verifySdkLicenseFilePath];
     _context = [NvsStreamingContext sharedInstance];

    NSString *SoulfxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"C6273A8F-C899-4765-8BFC-E683EE37AA84.videofx"];
    NSString *SoulfxLicPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"C6273A8F-C899-4765-8BFC-E683EE37AA84.lic"];

    
    NSString *ScalefxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"A8A4344D-45DA-460F-A18F-C0E2355FE864.videofx"];
    NSString *ScalefxLicPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"A8A4344D-45DA-460F-A18F-C0E2355FE864.lic"];
    
    
    NSString *jzfxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"9AC28816-639F-4A9B-B4BA-4060ABD229A2.videofx"];
    NSString *jzfxLicPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"9AC28816-639F-4A9B-B4BA-4060ABD229A2.lic"];

    NSString *jxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"6B7BE12C-9FA1-4ED0-8E81-E107632FFBC8.videofx"];
    NSString *jxLicPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"6B7BE12C-9FA1-4ED0-8E81-E107632FFBC8.lic"];
    
    NSString *blackMagicPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"33F513E5-5CA2-4C23-A6D4-8466202EE698.videofx"];
    NSString *blackMagicLicPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"33F513E5-5CA2-4C23-A6D4-8466202EE698.lic"];
    
    [_context.assetPackageManager installAssetPackage:SoulfxPath license:SoulfxLicPath type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:nil];
    [_context.assetPackageManager installAssetPackage:ScalefxPath license:ScalefxLicPath type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:nil];
    [_context.assetPackageManager installAssetPackage:jzfxPath license:jzfxLicPath type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:nil];
    [_context.assetPackageManager installAssetPackage:jxPath license:jxLicPath type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:nil];
    [_context.assetPackageManager installAssetPackage:blackMagicPath license:blackMagicLicPath type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:nil];

    
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
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:_addedViews];
    [_videoFxView addFiltterViews:newArray];
    [_videoFxView setNeedCovert:_convert];
    [_videoFxView setFxType:_currentFxType];
    [_videoFxView setTintPositon:_position];
    
     _videoFxView.duration = _timeLine.duration/1000000.0;
    
     _videoTrack = [_timeLine getVideoTrackByIndex:0];
    
    if (_thumBailView) {
        _videoFxView.progressBackView = _thumBailView;
    }else{
        NvsThumbnailSequenceView *thumbnailSequence = [[NvsThumbnailSequenceView alloc] init];
        thumbnailSequence.stillImageHint = NO;
        thumbnailSequence.mediaFilePath = _filePath;
        thumbnailSequence.startTime = 0;
        thumbnailSequence.duration = _timeLine.duration;
        thumbnailSequence.thumbnailAspectRatio = 1.0;
        [thumbnailSequence setFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.bounds), 27)];
        [thumbnailSequence setClipsToBounds:NO];
        _videoFxView.progressBackView = thumbnailSequence;

    }
    
    [[FSMusicPlayer sharedPlayer] setFilePath:_musicUrl];

    
    [self.view setBackgroundColor:FSHexRGB(0x000f1e)];
}
-(void)controlVideo{
    if ([_context getStreamingEngineState] != NvsStreamingEngineState_Playback) {
        [self playVideoFromHead];
    }else{
        [self stopVideoForCrrentTime];
        
    }
}

-(void)stopVideoForCrrentTime{
    [_videoFxView stopMoveTint];
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
        
        // 只有自动播放 修改光标位置
        [_videoFxView startMoveTint];
        [_controlView setState:YES];
        [[FSMusicPlayer sharedPlayer] playAtTime:startTime/1000000.0+_musicAttime];
        [[FSMusicPlayer sharedPlayer] play];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NvsAudioTrack *audiotrack = [_timeLine getAudioTrackByIndex:0];
    [audiotrack setVolumeGain:_musicUrl?0:1 rightVolumeGain:_musicUrl?0:1];
    
    if (![_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster]){
        NSLog(@"Failed to seek timeline!");
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_videoFxView stopMoveTint];
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
    [cancle setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Cancel"] forState:(UIControlStateNormal)];
    [cancle sizeToFit];
    cancle.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [cancle setFrame:CGRectMake(20, 20, 100, 24)];
    [self.view addSubview:cancle];
    
    UIButton *save = [[UIButton alloc] init];
    [save addTarget:self action:@selector(save) forControlEvents:(UIControlEventTouchUpInside)];
    [save setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Save"] forState:(UIControlStateNormal)];
    [save sizeToFit];
    [save setFrame:CGRectMake(self.view.frame.size.width-20-100, 20, 100, 24)];
    save.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.view addSubview:save];
}
- (void)cancle{
    
    [self restTimeLineFx];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)restTimeLineFx{
    [self removeAllFx];
    // 回归到之前的状态
    FSVirtualTimeLine *virTimeLine = [_fxOperationStack topVirtualTimeLine];
    //
    [self addVideoFxWithVirtualTimeline:virTimeLine];
}

-(void)removeAllFx{
    NvsTimelineVideoFx *lastVideoFx = [_timeLine getLastTimelineVideoFx];
    while (lastVideoFx) {
        // 删除所有的
        [_timeLine removeTimelineVideoFx:lastVideoFx];
        lastVideoFx = [_timeLine getLastTimelineVideoFx];
    }
}
- (void)addVideoFxWithVirtualTimeline:(FSVirtualTimeLine *)vTimeLine{
    NSArray *videoFxs = [vTimeLine allVideoFxs];
    
    for (FSVideoFx *fx in videoFxs) {
        
        int64_t startTime = fx.startPoint;
        int64_t duration = fx.endPoint - fx.startPoint;
        
        if(fx.convert != _convert){
            // 不能对应当前轨道的特效 那就翻转
            startTime = _timeLine.duration - fx.endPoint;
        }
        
        [_timeLine addPackagedTimelineVideoFx:startTime duration:duration videoFxPackageId:fx.videoFxId];
    }
}

- (void)save{
    // 保存当前的处理堆栈状态
    [_fxOperationStack popAll];
    [_fxOperationStack pushVideoFxWithFxManager:_tempFxStack];
    
    [self.addedViews removeAllObjects];
    [self.addedViews addObjectsFromArray:_videoFxView.addedViews];
    
    if ([self.delegate respondsToSelector:@selector(videoFxControllerSaved:fxType:position:convert:)]) {
        [self.delegate videoFxControllerSaved:[self.addedViews copy] fxType:_selectType position:_position convert:_convert];
    }
    
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
    [_videoFxView stopMoveTint];
    [[FSMusicPlayer sharedPlayer] stop];
}
#pragma mark -
-(void)videoFxViewNeedConvertView:(BOOL)convert type:(FSVideoFxType)type{
    
    _convert = convert;
    _selectType = type;
    
    [self removeAllFx];
    
    NSString *newPath = convert?_convertFilePath:_filePath;
    [_timeLine removeVideoTrack:0];
     _videoTrack = [_timeLine appendVideoTrack];
    [_videoTrack insertClip:newPath clipIndex:0];
    [_context seekTimeline:_timeLine timestamp:0 videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
    //
    FSVirtualTimeLine *vtimelin = [_tempFxStack topVirtualTimeLine];
    [self addVideoFxWithVirtualTimeline:vtimelin];
    
    if (convert) {
        [self playVideoFromHead];
    }
}

-(void)videoFxSelectTimeLinePosition:(FSVideoFxView *)videoFxView position:(CGFloat)progress shouldPlay:(BOOL)play{
    int64_t startPoint = _timeLine.duration * progress;
    [_context seekTimeline:_timeLine timestamp:startPoint videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
    [_controlView setState:NO];
    [[FSMusicPlayer sharedPlayer] stop];
    
    if (play) {
        [_context playbackTimeline:_timeLine startTime:startPoint endTime:_timeLine.duration videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) preload:YES flags:0];
        [_controlView setState:YES];
        [[FSMusicPlayer sharedPlayer] playAtTime:startPoint/1000000.0 + _musicAttime];
        [[FSMusicPlayer sharedPlayer] play];
    }
}

// 选择开始的节点
-(void)videoFxSelectStart:(FSVideoFxView *)videoFxView progress:(CGFloat)progress packageFxId:(NSString *)fxId{
    
    [videoFxView stopMoveTint];
    if (fxId != nil) {
        _startProgress = progress;
        int64_t startPoint = _timeLine.duration * _startProgress;
        // 添加特效
        [_timeLine addPackagedTimelineVideoFx:startPoint duration:_timeLine.duration videoFxPackageId:fxId];
        [_context seekTimeline:_timeLine timestamp:startPoint videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
        [_context playbackTimeline:_timeLine startTime:startPoint endTime:_timeLine.duration videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) preload:YES flags:0];
        [_controlView setState:YES];
        [[FSMusicPlayer sharedPlayer] playAtTime:startPoint/1000000.0 + _musicAttime];
        [[FSMusicPlayer sharedPlayer] play];
    }
}
// 选择结束的节点
-(void)videoFxSelectEnd:(FSVideoFxView *)videoFxView progress:(CGFloat)progress packageFxId:(NSString *)fxId{
    int64_t startPoint = _timeLine.duration * _startProgress;
    CGFloat endProgress = progress;
    int64_t endPoint = _timeLine.duration * endProgress;
    if (startPoint >= endPoint) {
        return;
    }
    
    NvsTimelineVideoFx *timeLineFx = [_timeLine getLastTimelineVideoFx];
    [timeLineFx changeInPoint:startPoint];
    [timeLineFx changeOutPoint:endPoint];
    
    FSVirtualTimeLine *lastVTimeLine = [_tempFxStack topVirtualTimeLine];
    
    FSVirtualTimeLine *willSaveTimeLine = [[FSVirtualTimeLine alloc] init];
    if (lastVTimeLine) {
         willSaveTimeLine.duration = _timeLine.duration;
        [willSaveTimeLine addVideoFxsInArray:[lastVTimeLine allVideoFxs]];
    }
    
    // 进入存储队列
    FSVideoFx *videoFx = [[FSVideoFx alloc] init];
    videoFx.startPoint = startPoint;
    videoFx.endPoint = endPoint;
    videoFx.videoFxId = fxId;
    videoFx.convert = _convert;
    //  加入特效
    [willSaveTimeLine addVideoFx:videoFx];
    // 记录
    [_tempFxStack pushObject:willSaveTimeLine];

    [self removeAllFx];
    [self addVideoFxWithVirtualTimeline:willSaveTimeLine];
    
    //
    [_context seekTimeline:_timeLine timestamp:endPoint videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
    
    [videoFxView stopMoveTint];
    [_controlView setState:NO];
    [[FSMusicPlayer sharedPlayer] stop];
    [videoFxView showUndoButton];
}
-(void)videoFxViewSelectTimeFx:(FSVideoFxView *)videoFxView type:(FSVideoFxType)type duration:(int64_t)duration progress:(CGFloat)progress{
    _selectType = type;
    int64_t point = _timeLine.duration * progress;
    _position = progress;
    
    if (type == FSVideoFxTypeSlow) {
        //缓慢
        
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
        
        NvsVideoClip *clip = [_videoTrack getClipWithIndex:0];

        [_videoTrack addClip:_filePath inPoint:point trimIn:(point - duration/2.0) trimOut:(point + duration/2.0)];
        [_videoTrack addClip:_filePath inPoint:point trimIn:(point - duration/2.0) trimOut:(point + duration/2.0)];
        [_videoTrack addClip:_filePath inPoint:point trimIn:(point - duration/2.0) trimOut:(point + duration/2.0)];
    }
    
    [_context playbackTimeline:_timeLine startTime:point endTime:_timeLine.duration videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) preload:YES flags:0];
    [_controlView setState:YES];
    [_videoFxView startMoveTint];
    [[FSMusicPlayer sharedPlayer] playAtTime:point/1000000.0 + _musicAttime];
    [[FSMusicPlayer sharedPlayer] play];
    
    videoFxView.duration = _timeLine.duration;
}
-(void)videoFxUndoPackageFx:(FSVideoFxView *)videoFxView{
    
    [_tempFxStack popVirtualTimeLine];
    FSVirtualTimeLine *shouldBe = _tempFxStack.topVirtualTimeLine;
    
    [self removeAllFx];

    [self addVideoFxWithVirtualTimeline:shouldBe];
    
//    if (![_timeLine getLastTimelineVideoFx]) {
//        [videoFxView hideUndoButton];
//    }
}
// 当前的位置进度
-(CGFloat)videoFxViewUpdatePosition:(FSVideoFxView *)videoFxView{
    int64_t currentPoint = [_context getTimelineCurrentPosition:_timeLine];
    CGFloat position = (CGFloat)currentPoint/_timeLine.duration;
    return position;
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
