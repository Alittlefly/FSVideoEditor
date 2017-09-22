//
//  FSPublisherController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/23.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSPublisherController.h"
#import "FSVideoEditorCommenData.h"

#import "NvsStreamingContext.h"
#import "NvsTimeline.h"
#import "NvsVideoClip.h"
#import "NvsVideoTrack.h"
#import "NvsAudioTrack.h"
#import "NvsAudioClip.h"
#import "NvsVideoFrameRetriever.h"


#import "FSFilterView.h"
#import "FSEditorLoading.h"
#import "FSControlVolumeView.h"
#import "FSMusicController.h"
#import "FSCutMusicView.h"
#import "FSMusicManager.h"

#import "FSAlertView.h"

#import "FSShortLanguage.h"

#import "FSShortVideoRecorderManager.h"
#import "FSChallengeController.h"
#import "FSAnimationNavController.h"

#import "FSPublishSingleton.h"
#import "FSDraftManager.h"
#import "FSTimelineConfiger.h"
#import "FSPublisherMaskView.h"
#import "FSVideoPublisher.h"
#import "FSShortLanguage.h"

typedef NS_ENUM(NSInteger,FSPublishOperationType){
    FSPublishOperationTypeSaveToDraft,
    FSPublishOperationTypePublishToNet,
};

@interface FSPublisherController ()<NvsStreamingContextDelegate,UINavigationControllerDelegate,FSPublisherToolViewDelegate,FSFilterViewDelegate, FSControlVolumeViewDelegate, FSCutMusicViewDelegate,FSVideoFxControllerDelegate,FSMusicControllerDelegate, FSShortVideoRecorderManagerDelegate, FSChallengeControllerDelegate,FSVideoPublisherDelegate>
{
    
    CGFloat _scoreVolume;
    FSPublishOperationType _OperationType;
    
    FSDraftInfo *_tempDraftInfo;
    
    FSVideoPublishParam *_param;
    
    BOOL _inPublish;
}
@property(nonatomic,assign)NvsStreamingContext*context;
@property(nonatomic,assign)NvsVideoTrack *videoTrack;
@property(nonatomic,strong)NvsAudioTrack *audioTrack;


@property (nonatomic, strong) FSFilterView *filterView;
@property(nonatomic,strong)FSEditorLoading *loading;
@property(nonatomic,strong)NvsVideoFrameRetriever *frameRetriever;

@property (nonatomic, strong) FSControlVolumeView *volumeView;
@property (nonatomic, strong) FSCutMusicView *cutMusicView;
@property (nonatomic, strong) FSPublisherMaskView *maskView;

@property (nonatomic, assign) BOOL isEnterCutMusicView;
@property (nonatomic, strong) FSVideoFxOperationStack *fxOperationStack;

@property (nonatomic, strong) NSMutableArray *addedViews;
@property (nonatomic, strong) FSChallengeModel *challengeModel;

@property (nonatomic, copy) NSString *stickerVideoPath;

@property (nonatomic, assign) BOOL isStickerVideoFinished;
@property (nonatomic, copy) NSString *uploadVideoPath;
@property (nonatomic, strong) NvsTimeline *timeLine;


@end

@implementation FSPublisherController

-(NSMutableArray *)addedViews{
    if (!_addedViews) {
        _addedViews = [NSMutableArray array];
        [_addedViews addObjectsFromArray:_tempDraftInfo.vAddedFxViews];
    }
    return _addedViews;
}
-(FSEditorLoading *)loading{
    if (!_loading) {
        _loading = [[FSEditorLoading alloc] initWithFrame:self.view.bounds];
    }
    return _loading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[FSShortVideoRecorderManager sharedInstance] loadAllLocalfxs];

    [self.view setBackgroundColor:[UIColor blackColor]];
    // Do any additional setup after loading the view.
    _prewidow = [[NvsLiveWindow alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_prewidow];
    
    _maskView = [[FSPublisherMaskView alloc] init];
    [_maskView setFrame:self.view.bounds];
    [self.view addSubview:_maskView];
    
    _tempDraftInfo = [[FSDraftManager sharedManager] draftInfoWithPreInfo:_draftInfo];

    
    _toolView = [[FSPublisherToolView alloc] initWithFrame:self.view.bounds draftInfo:_tempDraftInfo];
    _toolView.backgroundColor = [UIColor clearColor];
    _toolView.delegate =self;
    [self.view addSubview:_toolView];
    
    _isEnterCutMusicView = NO;
 
    
    
    NSString *verifySdkLicenseFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"198-14-0f022a4d5bfa12d379d469e146c1e9bf.lic"];
    [NvsStreamingContext verifySdkLicenseFile:verifySdkLicenseFilePath];
    _context = [NvsStreamingContext sharedInstanceWithFlags:(NvsStreamingContextFlag_Support4KEdit)];
    
    NSString *_musicPath = _tempDraftInfo.vMusic.mPath;
    
    if (!_timeLine) {
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
        NvsVideoTrack *videotrack = [_timeLine appendVideoTrack];

        if (_tempDraftInfo.vTimefx.tFxType == FSVideoFxTypeRevert) {
            [videotrack appendClip:_tempDraftInfo.vConvertPath];

        }else{
            [videotrack appendClip:_tempDraftInfo.vOriginalPath];
        }
    }
    
    // 添加原音
    NvsAudioTrack *audioTrack = [_timeLine getAudioTrackByIndex:0];
    if (!audioTrack) {
        audioTrack = [_timeLine appendAudioTrack];
    }
    [audioTrack appendClip:_tempDraftInfo.vOriginalPath];
    [audioTrack setVolumeGain:_tempDraftInfo.vOriginalVolume rightVolumeGain:_tempDraftInfo.vOriginalVolume];
    
    // 视屏轨道
    _videoTrack = [_timeLine getVideoTrackByIndex:0];
    NvsVideoClip *clip = [_videoTrack getClipWithIndex:0];
    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
    // 填好clip了
    [FSTimelineConfiger configTimeline:_timeLine timeLineInfo:_tempDraftInfo];
    [_videoTrack setVolumeGain:0.0 rightVolumeGain:0.0];
    
    
    //  有没有没音乐
    BOOL haveMusic = _musicPath != nil && _musicPath.length != 0;
    BOOL musicVolumeChanged = !(_tempDraftInfo.vMusicVolume == -1);
    BOOL originalVolumChanged = !(_tempDraftInfo.vOriginalVolume == -1);


    [_toolView canEditMusic:haveMusic];
    
    if (_tempDraftInfo.vMusic) {
        [_toolView updateMusicInfo:[_tempDraftInfo.vMusic orginalMusic]];
    }


    // 音频
    if (haveMusic) {
        // 有音乐
        NvsAudioTrack *musicTrack = [_timeLine getAudioTrackByIndex:1];
        if (!musicTrack) {
            musicTrack = [_timeLine appendAudioTrack];
        }
        [musicTrack appendClip:_musicPath];
        NvsAudioClip *musicClip = [musicTrack getClipWithIndex:0];
        [musicClip changeTrimInPoint:_tempDraftInfo.vMusic.mInPoint affectSibling:YES];
        //
        if (!musicVolumeChanged) {
            _tempDraftInfo.vMusicVolume = 0.5;
        }
        [musicTrack setVolumeGain:0.5 rightVolumeGain:0.5];
    }else{
        // 本地视频初始化
        if (!originalVolumChanged) {
            _tempDraftInfo.vOriginalVolume = 0.5;
            [audioTrack setVolumeGain:_tempDraftInfo.vOriginalVolume rightVolumeGain:_tempDraftInfo.vOriginalVolume];
        }
    }
    
    _param = [[FSVideoPublishParam alloc] init];
}

-(void)playVideoFromHead{
    if (_inPublish) {
        return;
    }
    
    [_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster];
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Playback){
        int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
        if(![_context playbackTimeline:_timeLine startTime:startTime endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:0]) {
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFromHead) name:UIApplicationDidBecomeActiveNotification object:nil];

    [self.toolView setHidden:NO];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_context connectTimeline:_timeLine withLiveWindow:_prewidow];
    [_context setDelegate:self];
    [self playVideoFromHead];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];

    [_context setDelegate:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
#pragma mark - 
-(void)chooseFilter{
    self.toolView.hidden = YES;

    if (!_filterView) {
        _filterView = [[FSFilterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-120, self.view.frame.size.width, 120) filterName:_tempDraftInfo.vFilterid];
        _filterView.backgroundColor = [UIColor clearColor];
        _filterView.hidden = YES;
        _filterView.delegate =self;
        [self.view addSubview:_filterView];
    }

    _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.view.frame.size.height, _filterView.frame.size.width, _filterView.frame.size.height);
    _filterView.hidden = NO;
    [UIView animateWithDuration:1 animations:^{
        _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.view.frame.size.height-_filterView.frame.size.height, _filterView.frame.size.width, _filterView.frame.size.height);

    }];
}

- (void)deleteCurrentCompileFile:(NSString *)outPutFilePath{
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath]) {
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:outPutFilePath error:&error] == NO) {
            NSLog(@"removeItemAtPath failed, error: %@", error);
        }
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

-(void)publishFiles{
    
    _inPublish = YES;
    
    [self.navigationController.view addSubview:self.loading];
    [self.loading loadingViewShow];
    [self.loading setLoadingText:[NSString stringWithFormat:@"%@",[FSShortLanguage CustomLocalizedStringFromTable:@"Processing"]]];
    
    NSLog(@"开始发布视频: -----");
    
    
    int64_t length = _timeLine.duration;
    NSString *_musicPath = _tempDraftInfo.vMusic.mPath;
    
    if (_musicPath != nil && _musicPath.length > 0) {
        NvsAudioTrack *_audiotrack = [_timeLine getAudioTrackByIndex:0];
        if (!_audiotrack) {
             _audiotrack = [_timeLine appendAudioTrack];
        }else{
            [_audiotrack removeAllClips];
        }
        NvsAudioClip *audio = [_audiotrack appendClip:_musicPath];
        int64_t _musicStartTime = _tempDraftInfo.vMusic.mInPoint;
        [audio changeTrimInPoint:_musicStartTime affectSibling:YES];
        [audio changeTrimOutPoint:length+_musicStartTime affectSibling:YES];
        [_audiotrack setVolumeGain:_tempDraftInfo.vMusicVolume rightVolumeGain:_tempDraftInfo.vMusicVolume];
    }else{
        // 原音
        [_videoTrack setVolumeGain:_tempDraftInfo.vOriginalVolume rightVolumeGain:_tempDraftInfo.vOriginalVolume];
        NvsAudioTrack *audiotrack = [_timeLine getAudioTrackByIndex:0];
        [audiotrack setVolumeGain:_tempDraftInfo.vOriginalVolume rightVolumeGain:_tempDraftInfo.vOriginalVolume];
    }

    //
    if (![_tempDraftInfo.vFinalPath isEqualToString:_tempDraftInfo.vOriginalPath]) {
        [self deleteCurrentCompileFile:_tempDraftInfo.vFinalPath];
    }
    _tempDraftInfo.vFinalPath = [self getCompilePath];

    _param.firstImageData = [_context grabImageFromTimeline:_timeLine timestamp:0 proxyScale:nil];
    _param.videoPath = _tempDraftInfo.vFinalPath;
    
    if([_context compileTimeline:_timeLine startTime:0 endTime:self.timeLine.duration outputFilePath:_tempDraftInfo.vFinalPath videoResolutionGrade:(NvsCompileVideoResolutionGradeCustom) videoBitrateGrade:(NvsCompileBitrateGradeMedium) flags:0]){
    }else {
        NSLog(@"0000000");
        [self.loading loadingViewhide];
        [self showFaildMesssage];
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    
    NSLog(@"%@",videoPath);
    
    NSLog(@"%@",error);

}

#pragma mark -
-(void)didPlaybackEOF:(NvsTimeline *)timeline{
    [self playVideoFromHead];
}
// 生成完成的回调函数
- (void)didCompileFinished:(NvsTimeline *)timeline{
    
    NSLog(@"Compile success!");
    if (_isStickerVideoFinished) {
        
        if (_tempDraftInfo.vSaveToAlbum) {
            UISaveVideoAtPathToSavedPhotosAlbum(_stickerVideoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
        
//        [self uploadFile:_stickerVideoPath];
        _param.draftInfo = _tempDraftInfo;
        
        [[FSVideoPublisher sharedPublisher] setDelegate:self];
        [[FSVideoPublisher sharedPublisher] publishVideo:_param];
        
    }else{
        // 首帧图已获取
        // 获取webp
        [[FSShortVideoRecorderManager sharedInstance] setDelegate:self];
        [[FSShortVideoRecorderManager sharedInstance] beginCreateWebP:_tempDraftInfo.vFinalPath];
    }
}
// 生成失败的回调函数
- (void)didCompileFailed:(NvsTimeline *)timeline {
    NSLog(@"Compile Failed!");
    
    [self.loading loadingViewhide];
    
    [self showFaildMesssage];
}
#pragma mark -
- (void)FSChallengeControllerChooseChallenge:(FSChallengeModel *)model {
    _challengeModel = model;
    FSDraftChallenge *draftChallenge = [[FSDraftChallenge alloc] init];
    draftChallenge.challengeId = model.challengeId;
    draftChallenge.challengeName = model.name;
    draftChallenge.challengeDetail = model.content;
    _tempDraftInfo.challenge = draftChallenge;
    
    [_toolView updateChallengeName:model.name];
}

#pragma mark - FSPublisherToolViewDelegate
- (void)FSPublisherToolViewRemovechallenge{
    _tempDraftInfo.challenge = nil;
}
- (void)FSPublisherToolViewShowChallengeView {
    FSChallengeController *challengeVC = [[FSChallengeController alloc] init];
    challengeVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:challengeVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)FSPublisherToolViewPublished {
    _OperationType = FSPublishOperationTypePublishToNet;

    [self publishFiles];
}
- (void)FSPublisherToolViewQuit {
    
    if (_tempDraftInfo.vType == FSDraftInfoTypeVideo) {
        
        // 弹出提示
        UIAlertController *alertControlelr = [UIAlertController alertControllerWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"CanlceVideo"] message:[FSShortLanguage CustomLocalizedStringFromTable:@"GiveUpEdit"] preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Cancel"] style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Confirm"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [[FSDraftManager sharedManager] cancleOperate];
            [_context removeTimeline:_timeLine];
            [_context stop];
        }];
        
        [alertControlelr addAction:cancle];
        [alertControlelr addAction:sure];
        [self.navigationController presentViewController:alertControlelr animated:YES completion:nil];
    }else{
        
        // 弹出提示
        if (_tempDraftInfo.vTimefx != nil || _tempDraftInfo.stack != nil) {
            UIAlertController *alertControlelr = [UIAlertController alertControllerWithTitle:@"" message:[FSShortLanguage CustomLocalizedStringFromTable:@"CancelEditWarning"] preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *cancle = [UIAlertAction actionWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Cancel"] style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *sure = [UIAlertAction actionWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Confirm"]  style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
                _draftInfo.vTimefx = nil;
                _draftInfo.stack = nil;
                _draftInfo.vFilterid = nil;
                _draftInfo.vAddedFxViews = nil;
                
                [[FSDraftManager sharedManager] cancleOperate];
                [_context removeTimeline:_timeLine];
                [_context stop];
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            [alertControlelr addAction:cancle];
            [alertControlelr addAction:sure];
            [self.navigationController presentViewController:alertControlelr animated:YES completion:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    

}

- (void)FSPublisherToolViewEditMusic {
    NSString *_musicPath = _tempDraftInfo.vMusic.mPath;
    if (_musicPath !=nil && _musicPath.length > 0) {
        
        NvsAudioTrack *audioTrack = [_timeLine getAudioTrackByIndex:0];
        if (audioTrack) {
            [audioTrack setVolumeGain:0 rightVolumeGain:0];
        }
        
        NvsAudioTrack *musicTrack = [_timeLine getAudioTrackByIndex:1];
        if (musicTrack) {
            [musicTrack setVolumeGain:0 rightVolumeGain:0];
        }
        
        _isEnterCutMusicView = YES;
        
        int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
        if(![_context playbackTimeline:_timeLine startTime:startTime endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:0]) {
        }
        
        if (!_cutMusicView) {
            NSTimeInterval _musicStartTime = _tempDraftInfo.vMusic.mInPoint;

            _cutMusicView = [[FSCutMusicView alloc] initWithFrame:self.view.bounds filePath:_musicPath startTime:_musicStartTime/1000000.0 volume:_tempDraftInfo.vMusicVolume videoTime:_timeLine.duration/1000000.0 currentPlayTime:startTime/1000000.0];
            _cutMusicView.delegate = self;
            [self.view addSubview:_cutMusicView];
            _cutMusicView.hidden = YES;
        }
        self.toolView.hidden = YES;
        _cutMusicView.hidden = NO;
        
    }
}

- (void)FSPublisherToolViewAddEffects {
    
    [_context seekTimeline:_timeLine timestamp:[_context getTimelineCurrentPosition:_timeLine] videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster];
    
    FSVideoFxController *fxController = [[FSVideoFxController alloc] init];
    fxController.timeLine = _timeLine;
    fxController.draftInfo = _tempDraftInfo;
    fxController.delegate = self;
    fxController.addedViews = self.addedViews;

    _tempDraftInfo.stack = _fxOperationStack?:[FSVideoFxOperationStack new];
    _fxOperationStack = _tempDraftInfo.stack;
    fxController.fxOperationStack = _fxOperationStack;
    
    [self presentViewController:fxController animated:YES completion:nil];
}

- (void)FSPublisherToolViewAddFilter {
    [self chooseFilter];
}

- (void)FSPublisherToolViewEditVolume {
    if (!_volumeView) {
        
        BOOL haveMusic = _tempDraftInfo.vMusic.mPath != nil && _tempDraftInfo.vMusic.mPath != 0;
        BOOL musicVolumeChanged = !(_tempDraftInfo.vMusicVolume == -1);
        BOOL originalVolumChanged = !(_tempDraftInfo.vOriginalVolume == -1);
        //
        CGFloat origalVolume = _tempDraftInfo.vOriginalVolume;
        CGFloat musicVolume = _tempDraftInfo.vMusicVolume;
        if (!originalVolumChanged && !haveMusic) {
            origalVolume = 0.5;
        }
        //
        if (!musicVolumeChanged) {
            musicVolume = 0.5;
        }
        
         _volumeView = [[FSControlVolumeView alloc] initWithFrame:self.view.bounds scroe:musicVolume soundtrack:origalVolume];
        _volumeView.delegate = self;
        [self.view addSubview:_volumeView];
        _volumeView.hidden = YES;
    }
    self.toolView.hidden = YES;
    _volumeView.hidden = NO;
    
}

- (void)FSPublisherToolViewChooseMusic {
    
    [_context stop];
    
    FSMusicController *music = [FSMusicController new];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:music];
    [nav setNavigationBarHidden:YES];
    
    music.timeLine = _timeLine;
    music.pushed = YES;
    music.needSelfHeader = YES;
    music.shouldReturnMusic = YES;
    [music setDelegate:self];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)FSPublisherToolViewSaveToDraft {
    NSString *formatKey = [NSString stringWithFormat:@"%@",[FSDraftManager sharedManager].cacheKey];
    if (formatKey.length == 0 || formatKey == nil) {
        [_context stop];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNSNotificationVideoAppShouldShowLogin object:self];
        return;
    }
    //#warning 区分正序倒序，重复监测
    //UISaveVideoAtPathToSavedPhotosAlbum(_filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);

    _OperationType = FSPublishOperationTypeSaveToDraft;
    
    UIImage *image = [_context grabImageFromTimeline:_timeLine timestamp:0 proxyScale:nil];
    
    if (image) {
        if (_tempDraftInfo.vFirstFramePath) {
            [FSDraftFileManager deleteFile:_tempDraftInfo.vFirstFramePath];
        }
        NSString *imagePath = [FSDraftFileManager saveImageTolocal:image];
        _tempDraftInfo.vFirstFramePath = imagePath;
    }
    _tempDraftInfo.vAddedFxViews = self.addedViews;
    
    [[FSDraftManager sharedManager] mergeInfo];
    [[FSDraftManager sharedManager] saveToLocal];
    [[FSDraftManager sharedManager] cancleOperate];
    
    [_context clearCachedResources:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)FSPublisherToolViewSaveToLibrary:(BOOL)isSave {
    
    // 权限检测
    
    _tempDraftInfo.vSaveToAlbum = isSave;
}

- (void)FSPublisherToolViewChangeVideoDescription:(NSString *)description {
    _tempDraftInfo.vTitle = description;
}

#pragma mark - 
-(void)musicControllerSelectMusic:(NSString *)musicPath music:(FSMusic *)music{
    if (music != nil && musicPath.length > 0) {
        [_toolView canEditMusic:YES];
        [_toolView updateMusicInfo:music];
        
        NvsAudioTrack *musicTrack = [_timeLine getAudioTrackByIndex:1];
        if (!musicTrack) {
             musicTrack =  [_timeLine appendAudioTrack];

        }
        [musicTrack removeAllClips];
        [musicTrack appendClip:musicPath];

        // 原音音轨
        NvsAudioTrack *audioTrack = [_timeLine getAudioTrackByIndex:0];
        _tempDraftInfo.vOriginalVolume = -1;
        [audioTrack setVolumeGain:0.0 rightVolumeGain:0.0];
        
        if (_tempDraftInfo.vMusicVolume == -1) {
            _tempDraftInfo.vMusicVolume = 0.5;
        }
        
        [musicTrack setVolumeGain:_tempDraftInfo.vMusicVolume rightVolumeGain:_tempDraftInfo.vMusicVolume];
        
        [self playVideoFromHead];
    }
}

- (void)musicControllerHideen {
    [self playVideoFromHead];
}

#pragma mark -
- (void)FSFilterViewFinishedChooseFilter {
    [UIView animateWithDuration:0.5 animations:^{
        _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.view.frame.size.height, _filterView.frame.size.width, _filterView.frame.size.height);
        
    } completion:^(BOOL finished) {
        _filterView.hidden = YES;
        [_filterView removeFromSuperview];
        _filterView.delegate = nil;
        _filterView= nil;
        _toolView.hidden = NO;
        
        
        [_toolView finishChangeFilter:_tempDraftInfo.vFilterid];
    }];
}

- (void)FSFilterViewChooseFilter:(NSString *)filter {
    _tempDraftInfo.vFilterid = filter;

    if ([filter isEqualToString:@"NoFilter"]) {
        for (unsigned int i = 0; i < _videoTrack.clipCount; i++)
            [[_videoTrack getClipWithIndex:i] removeAllFx];
        if (_tempDraftInfo.vBeautyOn) {
            
        }
    } else if ([filter isEqualToString:@"Package1"]) {
        for (unsigned int i = 0; i < _videoTrack.clipCount; i++) {
            NvsVideoClip *videoClip = [_videoTrack getClipWithIndex:i];
//            [videoClip removeAllFx];
//            [videoClip appendPackagedFx:filter];     // 追加包裹特效
            [[FSShortVideoRecorderManager sharedInstance] addFilter:filter toVideoClip:videoClip];

        }
    } else {
        for (unsigned int i = 0; i < _videoTrack.clipCount; i++) {
            NvsVideoClip *videoClip = [_videoTrack getClipWithIndex:i];
            [[FSShortVideoRecorderManager sharedInstance] addFilter:filter toVideoClip:videoClip];
        }
    }
    [FSDraftManager sharedManager].tempInfo.vFilterid = filter;
    [self seekTimeline];
}

- (void)seekTimeline {

    if (![_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster])
        NSLog(@"Failed to seek timeline!");
    [self playVideoFromHead];
}

#pragma mark - FSControlVolumeViewDelegate
- (void)FSControlVolumeViewChangeScore:(CGFloat)value {
    NSLog(@"%f  %u",value,[_timeLine audioTrackCount]);
    _tempDraftInfo.vMusicVolume = value;
    NvsAudioTrack *audioTrack = [_timeLine getAudioTrackByIndex:1];
    [audioTrack setVolumeGain:value rightVolumeGain:value];
}

- (void)FSControlVolumeViewChangeSoundtrack:(CGFloat)value {
    _tempDraftInfo.vOriginalVolume = value;
    NvsAudioTrack *audioTrack = [_timeLine getAudioTrackByIndex:0];
    [audioTrack setVolumeGain:(_tempDraftInfo.vOriginalVolume == -1)?0:_tempDraftInfo.vOriginalVolume rightVolumeGain:(_tempDraftInfo.vOriginalVolume == -1)?0:_tempDraftInfo.vOriginalVolume];
}

- (void)FSControlVolumeViewChangeFinished {
    _volumeView.hidden = YES;
    [_volumeView removeFromSuperview];
    _volumeView.delegate = nil;
    _volumeView = nil;
    self.toolView.hidden = NO;
}

- (void)FSCutMusicViewFinishCutMusicWithTime:(NSTimeInterval)newStartTime {
    _tempDraftInfo.vMusic.mInPoint = newStartTime*1000000;
    _isEnterCutMusicView = NO;
    
    NvsAudioTrack *musicTrack = [_timeLine getAudioTrackByIndex:1];
    [musicTrack removeAllClips];
    NvsAudioClip *musicClip = [musicTrack appendClip:_tempDraftInfo.vMusic.mPath];
    [musicClip changeTrimInPoint:newStartTime*1000000.0 affectSibling:YES];
    [musicTrack setVolumeGain:_tempDraftInfo.vMusicVolume rightVolumeGain:_tempDraftInfo.vMusicVolume];

    [self playVideoFromHead];
    
    _cutMusicView.hidden = YES;
    [_cutMusicView removeFromSuperview];
    _cutMusicView = nil;
    
    self.toolView.hidden = NO;
}
#pragma mark -
-(void)videoFxControllerSaved:(NSArray *)addedViews{
    
    [self.addedViews removeAllObjects];
    [self.addedViews addObjectsFromArray:addedViews];
}

#pragma mark -
- (void)FSShortVideoRecorderManagerConvertorFinished:(NSString *)filePath {
    _param.webpPath = filePath;
    
    [self addSticker:nil];
}
- (void)FSShortVideoRecorderManagerConvertorFaild {
    [self.loading loadingViewhide];
    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadFailed"]];
}
- (void)addSticker:(NSString *)filePath {
    [[FSShortVideoRecorderManager sharedInstance] addSticker:nil timeLine:_timeLine liveWindow:_prewidow];
    _stickerVideoPath = [self getCompilePath];
    _param.videoPathWithLogo = _stickerVideoPath;
    _isStickerVideoFinished = YES;
    [self compileFile:_stickerVideoPath];
}
- (void)compileFile:(NSString *)outputPath {
    int64_t length = _timeLine.duration;
    NSString *_musicPath = _tempDraftInfo.vMusic.mPath;
    
    if (_musicPath != nil && _musicPath.length > 0) {
        NvsAudioTrack *_audiotrack = [_timeLine getAudioTrackByIndex:0];
        if (!_audiotrack) {
            _audiotrack = [_timeLine appendAudioTrack];
        }else{
            [_audiotrack removeAllClips];
        }
        NvsAudioClip *audio = [_audiotrack appendClip:_musicPath];
        int64_t _musicStartTime = _tempDraftInfo.vMusic.mInPoint;
        [audio changeTrimInPoint:_musicStartTime affectSibling:YES];
        [audio changeTrimOutPoint:length+_musicStartTime affectSibling:YES];
        [_audiotrack setVolumeGain:_tempDraftInfo.vMusicVolume rightVolumeGain:_tempDraftInfo.vMusicVolume];
    }else{
        // 原音
        [_videoTrack setVolumeGain:_tempDraftInfo.vOriginalVolume rightVolumeGain:_tempDraftInfo.vOriginalVolume];
        NvsAudioTrack *audiotrack = [_timeLine getAudioTrackByIndex:0];
        [audiotrack setVolumeGain:_tempDraftInfo.vOriginalVolume rightVolumeGain:_tempDraftInfo.vOriginalVolume];
    }
    
    if([_context compileTimeline:_timeLine startTime:0 endTime:self.timeLine.duration outputFilePath:outputPath videoResolutionGrade:(NvsCompileVideoResolutionGradeCustom) videoBitrateGrade:(NvsCompileBitrateGradeMedium) flags:0]){
        NSLog(@"11111111");
    }
    else {
        [self.loading loadingViewhide];
        [self showFaildMesssage];
    }
}


#pragma mark - FSPublisherServerDelegate
-(void)videoPublisherProgress:(CGFloat)progress{
    NSLog(@"发布视频:更新进度:%f",progress);
    [self.loading setLoadingText:[NSString stringWithFormat:@"%.0f%%",MIN(progress * 100.0,100.0)]];
}
-(void)videoPublisherSuccess{
    [self.loading loadingViewhide];
    
    [[FSPublishSingleton sharedInstance] cleanData];
    [[FSDraftManager sharedManager] delete:_draftInfo];
    [[FSDraftManager sharedManager] clearInfo];
    [self deleteCurrentCompileFile:_stickerVideoPath];
    [[FSDraftManager sharedManager] cancleOperate];
    
    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadSecceed"]];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    _inPublish = NO;
}
-(void)videoPublisherFaild{
    [self.loading loadingViewhide];
    
    [self deleteCurrentCompileFile:_stickerVideoPath];
    
    [[FSShortVideoRecorderManager sharedInstance] removeSticker:_timeLine];
    
    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadFailed"]];
    
    _isStickerVideoFinished = NO;
    _inPublish = NO;
    
    [self playVideoFromHead];
}

- (void)showSuccessMessage{
    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadSecceed"]];
}
- (void)showFaildMesssage{
    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadFailed"]];
}

- (void)showMessage:(NSString *)message {
    FSAlertView *alertView = [[FSAlertView alloc] init];
    [alertView showWithMessage:message];
}

#pragma mark -
-(void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

@end
