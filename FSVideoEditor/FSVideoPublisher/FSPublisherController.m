//
//  FSPublisherController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/23.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSPublisherController.h"

#import "NvsStreamingContext.h"
#import "NvsTimeline.h"
#import "NvsVideoClip.h"
#import "NvsVideoTrack.h"
#import "NvsAudioTrack.h"
#import "NvsAudioClip.h"
#import "NvsVideoFrameRetriever.h"


#import "FSFilterView.h"
#import "FSUploader.h"
#import "FSEditorLoading.h"
#import "FSControlVolumeView.h"
#import "FSMusicController.h"
#import "FSCutMusicView.h"
#import "FSMusicManager.h"

#import "FSPublisherServer.h"
#import "FSAlertView.h"

#import "FSShortLanguage.h"

#import "FSUploadImageServer.h"
#import "FSShortVideoRecorderManager.h"
#import "FSChallengeController.h"
#import "FSAnimationNavController.h"

#import "FSPublishSingleton.h"
#import "FSDraftManager.h"
#import "FSTimelineConfiger.h"


typedef NS_ENUM(NSInteger,FSPublishOperationType){
    FSPublishOperationTypeSaveToDraft,
    FSPublishOperationTypePublishToNet,
};

@interface FSPublisherController ()<NvsStreamingContextDelegate,UINavigationControllerDelegate,FSPublisherToolViewDelegate,FSFilterViewDelegate,FSUploaderDelegate, FSControlVolumeViewDelegate, FSCutMusicViewDelegate,FSVideoFxControllerDelegate,FSMusicControllerDelegate, FSPublisherServerDelegate, FSUploadImageServerDelegate, FSShortVideoRecorderManagerDelegate, FSChallengeControllerDelegate>
{
    FSUploader *_uploader;
    
    CGFloat _scoreVolume;
    FSPublishOperationType _OperationType;
    
    FSDraftInfo *_tempDraftInfo;
}
@property(nonatomic,assign)NvsStreamingContext*context;
@property(nonatomic,assign)NvsVideoTrack *videoTrack;


@property (nonatomic, strong) FSFilterView *filterView;
@property(nonatomic,strong)FSEditorLoading *loading;
@property(nonatomic,strong)NvsVideoFrameRetriever *frameRetriever;

@property (nonatomic, strong) FSControlVolumeView *volumeView;
@property (nonatomic, strong) FSCutMusicView *cutMusicView;

@property (nonatomic, assign) BOOL isEnterCutMusicView;
@property (nonatomic, strong) FSVideoFxOperationStack *fxOperationStack;

@property (nonatomic, strong) NSMutableArray *addedViews;

@property (nonatomic, strong) FSPublisherServer *publishServer;
@property (nonatomic, strong) FSUploadImageServer *uploadImageServer;

@property (nonatomic, copy) NSString *firstImageUrl;
@property (nonatomic, copy) NSString *webpUrl;

@property (nonatomic, strong) FSChallengeModel *challengeModel;

@property (nonatomic, copy) NSString *stickerVideoPath;

@property (nonatomic, assign) BOOL isStickerVideoFinished;
@property (nonatomic, copy) NSString *uploadVideoPath;

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
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    // Do any additional setup after loading the view.
    _prewidow = [[NvsLiveWindow alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_prewidow];
    
    _toolView = [[FSPublisherToolView alloc] initWithFrame:self.view.bounds draftInfo:_draftInfo];
    _toolView.backgroundColor = [UIColor clearColor];
    _toolView.delegate =self;
    [self.view addSubview:_toolView];
    
    _isEnterCutMusicView = NO;
 
    
    _tempDraftInfo = [[FSDraftManager sharedManager] draftInfoWithPreInfo:_draftInfo];
    
    NSString *verifySdkLicenseFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"198-14-b5a2105bee06464eebd11f55a77db670.lic"];
    [NvsStreamingContext verifySdkLicenseFile:verifySdkLicenseFilePath];
    _context = [NvsStreamingContext sharedInstanceWithFlags:(NvsStreamingContextFlag_Support4KEdit)];
    
    NSString *_musicPath = _tempDraftInfo.vMusic.mPath;
    
    if (!_timeLine) {
        NvsVideoResolution videoEditRes;
        videoEditRes.imageWidth = 720;
        videoEditRes.imageHeight = 1280;
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
    
    
    FSFileSliceDivider *divider = [[FSFileSliceDivider alloc] initWithSliceCount:1];
     _uploader = [FSUploader uploaderWithDivider:divider];
    [_uploader setDelegate:self];
    
    //  有没有没音乐
    BOOL haveMusic = _musicPath != nil && _musicPath.length != 0;
    BOOL musicVolumeChanged = !(_tempDraftInfo.vMusicVolume == -1);
    BOOL originalVolumChanged = !(_tempDraftInfo.vOriginalVolume == -1);


    [_toolView canEditMusic:haveMusic];

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
        [musicTrack setVolumeGain:_tempDraftInfo.vMusicVolume rightVolumeGain:_tempDraftInfo.vMusicVolume];
    }else{
        // 本地视频初始化
        if (!originalVolumChanged && _tempDraftInfo.vType == FSDraftInfoTypeVideo) {
            _tempDraftInfo.vOriginalVolume = 0.5;
            [audioTrack setVolumeGain:_tempDraftInfo.vOriginalVolume rightVolumeGain:_tempDraftInfo.vOriginalVolume];
        }
    }
}

-(void)playVideoFromHead{
    [_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster];
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Playback){
        int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
        if(![_context playbackTimeline:_timeLine startTime:startTime endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:0]) {
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];

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
    [_context setDelegate:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
#pragma mark - 
-(void)chooseFilter{
    self.toolView.hidden = YES;

    if (!_filterView) {
        _filterView = [[FSFilterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-120, self.view.frame.size.width, 120)];
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
    [self.navigationController.view addSubview:self.loading];
    [self.loading loadingViewShow];
    
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

    if([_context compileTimeline:_timeLine startTime:0 endTime:self.timeLine.duration outputFilePath:_tempDraftInfo.vFinalPath videoResolutionGrade:(NvsCompileVideoResolutionGrade720) videoBitrateGrade:(NvsCompileBitrateGradeLow) flags:0]){
        NSLog(@"11111111");
    }
    else {
        NSLog(@"0000000");
        [self.loading loadingViewhide];

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
        [self uploadFile:_stickerVideoPath];
        
        if (_tempDraftInfo.vSaveToAlbum) {
            UISaveVideoAtPathToSavedPhotosAlbum(_stickerVideoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    else {
        UIImage *image = [[FSShortVideoRecorderManager sharedInstance] getImageFromTimeLine:timeline atTime:0 proxyScale:nil];//[[FSShortVideoRecorderManager sharedInstance] getImageFromFile:_tempDraftInfo.vFinalPath atTime:0 videoFrameHeightGrade:NvsVideoFrameHeightGrade480];
        [self uploadFirstImage:image];
        //UISaveVideoAtPathToSavedPhotosAlbum(_tempDraftInfo.vFinalPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);

    }
    

}
// 生成失败的回调函数
- (void)didCompileFailed:(NvsTimeline *)timeline {
    NSLog(@"Compile Failed!");
    
    [self.loading loadingViewhide];

}
#pragma mark -
- (void)FSChallengeControllerChooseChallenge:(FSChallengeModel *)model {
    _challengeModel = model;
    FSDraftChallenge *draftChallenge = [[FSDraftChallenge alloc] init];
    draftChallenge.challengeId = model.challengeId;
    draftChallenge.challengeName = model.name;
    draftChallenge.challengeDetail = model.content;
    _tempDraftInfo.challenge = draftChallenge;
    
    [FSPublishSingleton sharedInstance].chooseChallenge = model;
    [_toolView updateChallengeName:model.name];
}

#pragma mark - FSPublisherToolViewDelegate
- (void)FSPublisherToolViewShowChallengeView {
    FSChallengeController *challengeVC = [[FSChallengeController alloc] init];
    challengeVC.delegate = self;
    FSAnimationNavController *nav = [[FSAnimationNavController alloc] initWithRootViewController:challengeVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)FSPublisherToolViewPublished {
    _OperationType = FSPublishOperationTypePublishToNet;

    [self publishFiles];
}
- (void)FSPublisherToolViewQuit {
    
    if (_tempDraftInfo.vType == FSDraftInfoTypeVideo) {
        
        // 弹出提示
        UIAlertController *alertControlelr = [UIAlertController alertControllerWithTitle:@"" message:[FSShortLanguage CustomLocalizedStringFromTable:@"CanlceVideo"] preferredStyle:(UIAlertControllerStyleAlert)];
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
        // 弹出提示
        UIAlertController *alertControlelr = [UIAlertController alertControllerWithTitle:@"" message:[FSShortLanguage CustomLocalizedStringFromTable:@"CancelEditWarning"] preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Cancel"] style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Confirm"]  style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
            [[FSDraftManager sharedManager] cancleOperate];
            [_context removeTimeline:_timeLine];
            [_context stop];
        }];
        
        [alertControlelr addAction:cancle];
        [alertControlelr addAction:sure];
        [self.navigationController presentViewController:alertControlelr animated:YES completion:nil];
        
    }
    

}

- (void)FSPublisherToolViewEditMusic {
    
    NSString *_musicPath = _tempDraftInfo.vMusic.mPath;
    if (_musicPath !=nil && _musicPath.length > 0) {
        _isEnterCutMusicView = YES;
        
        if (!_cutMusicView) {
            NSTimeInterval _musicStartTime = _tempDraftInfo.vMusic.mInPoint;
            _cutMusicView = [[FSCutMusicView alloc] initWithFrame:self.view.bounds filePath:_musicPath startTime:_musicStartTime/1000000.0];
            _cutMusicView.delegate = self;
            [self.view addSubview:_cutMusicView];
            _cutMusicView.hidden = YES;
        }
        self.toolView.hidden = YES;
        _cutMusicView.hidden = NO;
    }
    
    [_context stop];
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

    FSAnimationNavController *nav = [[FSAnimationNavController alloc] initWithRootViewController:music];
    [nav setNavigationBarHidden:YES];
    
    music.timeLine = _timeLine;
    music.pushed = YES;
    music.needSelfHeader = YES;
    [music setDelegate:self];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)FSPublisherToolViewSaveToDraft {
    //#warning 区分正序倒序，重复监测
    //UISaveVideoAtPathToSavedPhotosAlbum(_filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    _OperationType = FSPublishOperationTypeSaveToDraft;
    
     UIImage *image = [[FSShortVideoRecorderManager sharedInstance] getImageFromTimeLine:_timeLine atTime:0 proxyScale:nil];
    
    if (image) {
        NSString *imagePath = [FSDraftFileManager saveImageTolocal:image];
        if (_tempDraftInfo.vFirstFramePath) {
            [FSDraftFileManager deleteFile:_tempDraftInfo.vFirstFramePath];
        }
        _tempDraftInfo.vFirstFramePath = imagePath;
    }
    // test
//    FSDraftChallenge *challenge = [[FSDraftChallenge alloc] init];
//    challenge.challengeDetail = @"challegeDatail";
//    challenge.challengeName = @"challengeName";
//    //
//    _tempDraftInfo.challenge = challenge;
    _tempDraftInfo.vAddedFxViews = self.addedViews;
    
    [[FSDraftManager sharedManager] mergeInfo];
    [[FSDraftManager sharedManager] saveToLocal];
    [[FSDraftManager sharedManager] cancleOperate];
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)FSPublisherToolViewSaveToLibrary:(BOOL)isSave {
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
        
        [self playVideoFromHead];
    }
}

#pragma mark -
- (void)FSFilterViewFinishedChooseFilter {
    [UIView animateWithDuration:1 animations:^{
        _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.view.frame.size.height, _filterView.frame.size.width, _filterView.frame.size.height);
        
    } completion:^(BOOL finished) {
        _filterView.hidden = YES;
        _toolView.hidden = NO;
    }];
}

- (void)FSFilterViewChooseFilter:(NSString *)filter {
    if ([filter isEqualToString:@"None"]) {
        for (unsigned int i = 0; i < _videoTrack.clipCount; i++)
            [[_videoTrack getClipWithIndex:i] removeAllFx];
    } else if ([filter isEqualToString:@"Package1"]) {
        for (unsigned int i = 0; i < _videoTrack.clipCount; i++) {
            NvsVideoClip *videoClip = [_videoTrack getClipWithIndex:i];
            [videoClip removeAllFx];
            [videoClip appendPackagedFx:filter];     // 追加包裹特效
        }
    } else {
        for (unsigned int i = 0; i < _videoTrack.clipCount; i++) {
            NvsVideoClip *videoClip = [_videoTrack getClipWithIndex:i];
            [videoClip removeAllFx];
            [videoClip appendBuiltinFx:filter];         // 追加内嵌特效
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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

- (NSString *)getNameFromPath:(NSString *)path {
    NSString *lastName = [path lastPathComponent];
    return [lastName stringByDeletingLastPathComponent];
}

- (void)uploadFirstImage:(UIImage *)image {
    if (!_uploadImageServer) {
        _uploadImageServer = [[FSUploadImageServer alloc] init];
        _uploadImageServer.delegate = self;
    }
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);

    NSData * imageData = UIImageJPEGRepresentation(image,1);
    
    CGFloat length = [imageData length]/1024;
    CGFloat bit = 1;
    if (length > 200) {
        bit = 200/length;
    }
    [_uploadImageServer uploadFirstImage:[NSDictionary dictionaryWithObjectsAndKeys:UIImageJPEGRepresentation(image,bit),@"imageData",[self getNameFromPath:_tempDraftInfo.vFinalPath],@"imageName",nil]];
}

- (void)FSUploadImageServerFirstImageSucceed:(NSString *)filePath {
    _firstImageUrl = filePath;

    [[FSShortVideoRecorderManager sharedInstance] setDelegate:self];
    [[FSShortVideoRecorderManager sharedInstance] beginCreateWebP:_tempDraftInfo.vFinalPath];
}

- (void)FSUploadImageServerFirstImageFailed:(NSError *)error {
    [self.loading loadingViewhide];
    
    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadFailed"]];
}

- (void)FSUploadImageServerWebPSucceed:(NSString *)filePath {
    _webpUrl = filePath;
    [self uploadFile:_tempDraftInfo.vFinalPath];
}

- (void)FSUploadImageServerWebPFailed:(NSError *)error {
    [self.loading loadingViewhide];
    
    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadFailed"]];
}

#pragma mark -
- (void)FSShortVideoRecorderManagerConvertorFinished:(NSString *)filePath {
    if (!_uploadImageServer) {
        _uploadImageServer = [[FSUploadImageServer alloc] init];
        _uploadImageServer.delegate = self;
    }
  //  UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    CGFloat length = [data length]/1024;
 
    CGFloat bit = 1;
    if (length > 1024) {
        bit = 1024/length;
    }
    [_uploadImageServer uploadWebP:[NSDictionary dictionaryWithObjectsAndKeys:data,@"webpData",[self getNameFromPath:_tempDraftInfo.vFinalPath],@"webpName",nil]];
}

- (void)FSShortVideoRecorderManagerConvertorFaild {
    [self.loading loadingViewhide];
    
    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadFailed"]];
}

- (void)addSticker:(NSString *)filePath {
    [[FSShortVideoRecorderManager sharedInstance] addSticker:nil timeLine:_timeLine];
    _stickerVideoPath = [self getCompilePath];
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
    
    
    
    if([_context compileTimeline:_timeLine startTime:0 endTime:self.timeLine.duration outputFilePath:outputPath videoResolutionGrade:(NvsCompileVideoResolutionGrade720) videoBitrateGrade:(NvsCompileBitrateGradeLow) flags:0]){
        NSLog(@"11111111");
    }
    else {
        NSLog(@"0000000");
        [self.loading loadingViewhide];
        
    }
}

#pragma mark -
- (void)uploadFile:(NSString *)filePath{
    __block FSPublisherController *weakSelf = self;
    [_uploader uploadFileWithFilePath:filePath complete:^(CGFloat progress, NSString *filePath, NSDictionary * info) {
        
        if (weakSelf.isStickerVideoFinished) {
            if (!info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.loading loadingViewhide];
                    [weakSelf showMessage:NSLocalizedString(@"UploadFailed", nil)];
                });
            }
            else {
                NSLog(@"uploadFile: %f  %@",progress,filePath);
                if (!_publishServer) {
                    _publishServer = [[FSPublisherServer alloc] init];
                    _publishServer.delegate = weakSelf;
                }
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
                [dic setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"loginKey"] forKey:@"loginKey"];
                [dic setValue:[NSNumber numberWithInt:4] forKey:@"requestType"];
                [dic setValue:[info objectForKey:@"dataInfo"] forKey:@"lvu"];
                [dic setValue:weakSelf.uploadVideoPath forKey:@"vu"];
                [dic setValue:_tempDraftInfo.vTitle?:@"" forKey:@"vd"]; //
                [dic setValue:_firstImageUrl?:@"" forKey:@"vp"];    //image
                [dic setValue:_webpUrl?:@"" forKey:@"vg"];   //webp
                [dic setValue:@([[FSDraftManager  sharedManager] tempInfo].vMusic.mId) forKey:@"si"]; //歌曲id
                [dic setValue:@([[FSDraftManager  sharedManager] tempInfo].challenge.challengeId) forKey:@"di"];  //挑战ID
                [dic setValue:[NSArray array] forKey:@"a"];  //消息[{"ui":12815,"nk":"tttty"},{"ui":90665,"nk":"ytest"}]
                //        [dic setValue:@"被@用户ID" forKey:@"ui"];
                //        [dic setValue:@"用户昵称" forKey:@"nk"];
                
                [_publishServer publisherVideo:dic];
            }
            weakSelf.isStickerVideoFinished = NO;

        }
        else {
            if(!info){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.loading loadingViewhide];
                    [weakSelf showMessage:NSLocalizedString(@"UploadFailed", nil)];
                });
            }
            else {
                weakSelf.uploadVideoPath = [info objectForKey:@"dataInfo"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.isStickerVideoFinished = YES;
                    [weakSelf addSticker:filePath];
                });
            }
        }
        
    }];
//    [_uploader uploadFileProgressWithFilePath:filePath complete:^(float progress, NSString *filePath) {
//        
//    }];
}
-(void)uploadUpFiles:(NSString *)filePath progress:(float)progress{
    NSLog(@"progress %.2f",progress);
}

-(void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark - FSPublisherServerDelegate
- (void)FSPublisherServerSucceed {
    [self.loading loadingViewhide];
    
    [[FSPublishSingleton sharedInstance] cleanData];
    [[FSDraftManager sharedManager] delete:_draftInfo];
    [[FSDraftManager sharedManager] clearInfo];
    [[FSDraftManager sharedManager] saveToLocal];
    [self deleteCurrentCompileFile:_stickerVideoPath];


    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadSecceed"]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)FSPublisherServerFailed:(NSError *)error {
    [self.loading loadingViewhide];

    [self deleteCurrentCompileFile:_stickerVideoPath];

    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadFailed"]];
}

- (void)showMessage:(NSString *)message {
    FSAlertView *alertView = [[FSAlertView alloc] init];
    [alertView showWithMessage:message];
}


@end
