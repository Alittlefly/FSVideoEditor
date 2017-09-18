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
#import "FSDraftManager.h"
#import "FSPublishSingleton.h"

@interface FSVideoFxController ()<NvsStreamingContextDelegate,FSVideoFxViewDelegate,UIViewControllerTransitioningDelegate>
{
    NSMutableString *_videoFxPackageId;
    
    CGFloat _startProgress;
    
    FSVideoFxOperationStack *_tempFxStack;
    
    
    
    FSDraftTimeFx *_timeFx;
    
    FSDraftInfo *_tempDraftInfo;
    
    BOOL _Willchanged;
}
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,copy)NSString *convertFilePath;
@property(nonatomic,assign)NSTimeInterval musicAttime;
@property(nonatomic,strong)NSString *musicUrl;
@property(nonatomic,assign)FSVideoFxType selectType;
@property(nonatomic,assign)BOOL convert;
@property(nonatomic,assign)CGFloat position;
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
    _Willchanged = NO;
    
    _musicAttime = _draftInfo.vMusic.mInPoint;
    _musicUrl = _draftInfo.vMusic.mPath;
    _filePath = _draftInfo.vOriginalPath;
    _convertFilePath = _draftInfo.vConvertPath;
    //
    FSDraftTimeFx *timeFx = _draftInfo.vTimefx;

    _selectType = timeFx?[timeFx tFxType]:FSVideoFxTypeNone;
    int64_t currentPoint = timeFx?timeFx.tFxInPoint:_timeLine.duration/2.0;
    _position = (CGFloat)currentPoint/_timeLine.duration;
    _convert = (_selectType == FSVideoFxTypeRevert);
    
    [self creatSubViews];
    
     _context = [NvsStreamingContext sharedInstanceWithFlags:(NvsStreamingContextFlag_Support4KEdit)];
    
    CGFloat maxHeight = CGRectGetHeight(self.view.bounds) - 228 - 54 - 12;
    CGFloat maxWidth = ((CGFloat)210.0/373.0) * maxHeight;
     _prewidow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds) - maxWidth)/2.0, 54, maxWidth, maxHeight)];
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
    [_videoFxView setFxType:_selectType];
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
    
    [_controlView setState:NO];
    [_videoFxView setIsPlaying:NO];
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
        [_videoFxView setIsPlaying:YES];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    [self.videoFxView creatFxFiltterButtons];
    
    if (![_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster]){
        NSLog(@"Failed to seek timeline!");
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:(UIStatusBarAnimationFade)];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:(UIStatusBarAnimationFade)];
     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

    [_videoFxView stopMoveTint];
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
    cancle.contentHorizontalAlignment = ![FSPublishSingleton sharedInstance].isAutoReverse?UIControlContentHorizontalAlignmentLeft:UIControlContentHorizontalAlignmentRight;
    CGFloat cancleX = [FSPublishSingleton sharedInstance].isAutoReverse?(CGRectGetWidth(self.view.bounds) - 120):20;
    [cancle setFrame:CGRectMake(cancleX, 20, 100, 24)];
    [self.view addSubview:cancle];
    
    UIButton *save = [[UIButton alloc] init];
    [save addTarget:self action:@selector(save) forControlEvents:(UIControlEventTouchUpInside)];
    [save setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Save"] forState:(UIControlStateNormal)];
    [save sizeToFit];
    CGFloat saveX = [FSPublishSingleton sharedInstance].isAutoReverse?20:(CGRectGetWidth(self.view.bounds) - 120);
    [save setFrame:CGRectMake(saveX, 20, 100, 24)];
    save.contentHorizontalAlignment = ![FSPublishSingleton sharedInstance].isAutoReverse?UIControlContentHorizontalAlignmentRight:UIControlContentHorizontalAlignmentLeft;;
    [self.view addSubview:save];
}
- (void)cancle{
    
    if (_Willchanged) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[FSShortLanguage CustomLocalizedStringFromTable:@"EraseEffectsTip"] preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Cancel"] style:(UIAlertActionStyleCancel) handler:nil];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Erase"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self rsetTimeLineFx];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertController addAction:cancle];
        [alertController addAction:sure];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else{
        [self rsetTimeLineFx];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)rsetTimeLineFx{
    [self removeAllFx];

    FSVirtualTimeLine *virTimeLine = [_fxOperationStack topVirtualTimeLine];
    //
    [self addVideoFxWithVirtualTimeline:virTimeLine];
    _draftInfo.stack = _fxOperationStack;
    // 回归到之前的状态
    
    FSDraftTimeFx *timeFx = _draftInfo.vTimefx;
    [_videoTrack removeAllClips];
    
    if(timeFx.tFxType == FSVideoFxTypeRevert){
        [_videoTrack appendClip:_draftInfo.vConvertPath];
    }else{
        [_videoTrack appendClip:_draftInfo.vOriginalPath];
    }
    
    [self addTimeFxWithFx:timeFx];
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
        
        if ([fx.videoFxId isEqualToString:@"Video Echo"])
            [_timeLine addBuiltinTimelineVideoFx:startTime duration:duration videoFxName:fx.videoFxId];
        else{
            [_timeLine addPackagedTimelineVideoFx:startTime duration:duration videoFxPackageId:fx.videoFxId];

        }
    }
}

- (void)save{
    // 保存当前的处理堆栈状态
     _draftInfo.stack = [_fxOperationStack copy];
     _draftInfo.vTimefx = _timeFx;
    
    [_fxOperationStack popAll];
    [_fxOperationStack pushVideoFxWithFxManager:_tempFxStack];
    
    [self.addedViews removeAllObjects];
    [self.addedViews addObjectsFromArray:_videoFxView.addedViews];
    

    if ([self.delegate respondsToSelector:@selector(videoFxControllerSaved:)]) {
        [self.delegate videoFxControllerSaved:[self.addedViews copy]];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma make -
-(void)didPlaybackEOF:(NvsTimeline *)timeline{
    if (![_context seekTimeline:timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster]){
        NSLog(@"Failed to seek timeline!");
    }

    [self playVideoFromHead];
}
-(void)didPlaybackStopped:(NvsTimeline *)timeline{
    
    [_controlView setState:NO];
    [_videoFxView setIsPlaying:NO];
    [_videoFxView stopMoveTint];

}
#pragma mark -
-(void)videoFxViewNeedConvertView:(BOOL)convert type:(FSVideoFxType)type{
    
    _convert = convert;
    _selectType = type;
    
    NSString *newPath = convert?_convertFilePath:_filePath;
    [_videoTrack removeAllClips];
    [_videoTrack appendClip:newPath];
    [_videoTrack setVolumeGain:0 rightVolumeGain:0];

    [_context seekTimeline:_timeLine timestamp:0 videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
    
    
    // 
    [self removeAllFx];
    FSVirtualTimeLine *vtimelin = [_tempFxStack topVirtualTimeLine];
    [self addVideoFxWithVirtualTimeline:vtimelin];
    
    if (convert) {
        [self playVideoFromHead];
    }
    
    FSDraftTimeFx *draftFx = [FSDraftTimeFx new];
    draftFx.tFxType = type;
    draftFx.tFxInPoint = 0;
    draftFx.tFxOutPoint = _timeLine.duration;
    _timeFx = draftFx;
}

-(void)videoFxSelectTimeLinePosition:(FSVideoFxView *)videoFxView position:(CGFloat)progress shouldPlay:(BOOL)play{
    int64_t startPoint = MAX(_timeLine.duration * progress - 1, 0);
    [_context seekTimeline:_timeLine timestamp:startPoint videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
    [_controlView setState:NO];
    [_videoFxView setIsPlaying:NO];
    
    if (play) {
        [_context playbackTimeline:_timeLine startTime:startPoint endTime:_timeLine.duration videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) preload:YES flags:0];
        [_controlView setState:YES];
        [_videoFxView setIsPlaying:YES];
    }
}

// 选择开始的节点
-(void)videoFxSelectStart:(FSVideoFxView *)videoFxView progress:(CGFloat)progress packageFxId:(NSString *)fxId{
    
    _Willchanged = YES;

    [videoFxView stopMoveTint];
    if (fxId != nil) {
        _startProgress = progress;
        int64_t startPoint = _timeLine.duration * _startProgress;
        // 添加特效
        if ([fxId isEqualToString:@"Video Echo"])
            [_timeLine addBuiltinTimelineVideoFx:startPoint duration:_timeLine.duration videoFxName:fxId];
        else{
            [_timeLine addPackagedTimelineVideoFx:startPoint duration:_timeLine.duration videoFxPackageId:fxId];
        }
        
        [_context seekTimeline:_timeLine timestamp:startPoint videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) flags:0];
        [_context playbackTimeline:_timeLine startTime:startPoint endTime:_timeLine.duration videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) preload:YES flags:0];
        [_controlView setState:YES];
        [videoFxView setIsPlaying:YES];
    }
}
// 选择结束的节点
-(void)videoFxSelectEnd:(FSVideoFxView *)videoFxView progress:(CGFloat)progress packageFxId:(NSString *)fxId{
    int64_t startPoint = _timeLine.duration * _startProgress;
    CGFloat endProgress = progress;
    int64_t endPoint = MAX(_timeLine.duration * endProgress - 1, 0) ;
    
    if (startPoint >= endPoint) {
        [self removeAllFx];
        FSVirtualTimeLine *lastVTimeLine = [_tempFxStack topVirtualTimeLine];
        [self addVideoFxWithVirtualTimeline:lastVTimeLine];
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
    [videoFxView setIsPlaying:NO];
    [videoFxView showUndoButton];
}
-(void)videoFxViewSelectTimeFx:(FSVideoFxView *)videoFxView type:(FSVideoFxType)type duration:(int64_t)duration progress:(CGFloat)progress{
    _selectType = type;
    int64_t point = _timeLine.duration * progress;
    _position = progress;
    // 清除
    [_videoTrack removeAllClips];
    [_videoTrack appendClip:_filePath];

    FSDraftTimeFx *draftFx = [FSDraftTimeFx new];
    draftFx.tFxType = type;
    draftFx.tFxInPoint = point;
    draftFx.tFxOutPoint = point + duration;;
    _timeFx = draftFx;
    
    [self addTimeFxWithFx:draftFx];
    //
    [_context playbackTimeline:_timeLine startTime:point endTime:_timeLine.duration videoSizeMode:(NvsVideoPreviewSizeModeLiveWindowSize) preload:YES flags:0];
    [_controlView setState:YES];
    [_videoFxView setIsPlaying:YES];
    [_videoFxView startMoveTint];
   
    videoFxView.duration = _timeLine.duration/1000000.0;
}

-(void)addTimeFxWithFx:(FSDraftTimeFx *)timeFx{
    //
    FSVideoFxType type = timeFx.tFxType;
    
    int64_t fxPos = timeFx.tFxInPoint;
    int64_t duration = timeFx.tFxOutPoint - timeFx.tFxInPoint;
    int64_t originalDuration = MIN(_timeLine.duration, 15000000.0) ;

    if (type == FSVideoFxTypeSlow) {
        //缓慢
        NvsVideoClip* newClip = [self splitClip:fxPos duration:duration];
        [newClip changeSpeed:0.5*newClip.getSpeed];
        
    }else if(type == FSVideoFxTypeRepeat){
        
        // 重复
        NvsVideoClip* newClip = [self splitClip:fxPos duration:duration];
        
        for (int i=0; i<2; i++) {
            NvsVideoClip* clip = [_videoTrack insertClip:newClip.filePath trimIn:newClip.trimIn trimOut:newClip.trimOut clipIndex:newClip.index];
            if (clip != nil)
                [clip changeSpeed:newClip.getSpeed];
        }
        
        for (int i=0; i<_videoTrack.clipCount-1; i++)
            [_videoTrack setBuiltinTransition:i withName:nil];
    }
    
    int64_t currentDuration = _timeLine.duration;
    if (currentDuration > originalDuration) {
        NvsVideoClip *trailClip = [_videoTrack getClipWithTimelinePosition:originalDuration];
        int64_t shouldBeTrimOut = trailClip.trimOut - (currentDuration - originalDuration);
        [trailClip changeTrimOutPoint:shouldBeTrimOut affectSibling:YES];
        
    }
    [_videoTrack setVolumeGain:0 rightVolumeGain:0];

}

- (NvsVideoClip*) splitClip:(int64_t)fxPoint duration:(int64_t)duration{
    bool tailer = false;
    int64_t fxPos = fxPoint;
    if (_timeLine.duration - fxPos <= duration) {
        fxPos = _timeLine.duration - duration;
        tailer = true;
    }
    if (![_videoTrack splitClip:[_videoTrack getClipWithTimelinePosition:fxPos].index splitPoint:fxPos])
        return nil;
    if (!tailer) {
        if (![_videoTrack splitClip:[_videoTrack getClipWithTimelinePosition:fxPos+duration].index splitPoint:fxPos+duration])
            return nil;
    }
    NvsVideoClip* newClip = [_videoTrack getClipWithTimelinePosition:fxPos];
    return newClip;
}
-(void)videoFxUndoPackageFx:(FSVideoFxView *)videoFxView{
    
    [_tempFxStack popVirtualTimeLine];
    FSVirtualTimeLine *shouldBe = _tempFxStack.topVirtualTimeLine;
    
    [self removeAllFx];

    [self addVideoFxWithVirtualTimeline:shouldBe];
}
-(void)videoFxViewChangeFilter{
    [_controlView setState:NO];
    [_context stop];
    [_videoFxView setIsPlaying:NO];
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
    [_videoFxView stopMoveTint];
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

@end
