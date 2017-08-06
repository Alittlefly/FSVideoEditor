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
#import "FSMusicPlayer.h"
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


typedef NS_ENUM(NSInteger,FSPublishOperationType){
    FSPublishOperationTypeSaveToDraft,
    FSPublishOperationTypePublishToNet,
};

@interface FSPublisherController ()<NvsStreamingContextDelegate,UINavigationControllerDelegate,FSPublisherToolViewDelegate,FSFilterViewDelegate,FSUploaderDelegate, FSControlVolumeViewDelegate, FSCutMusicViewDelegate,FSVideoFxControllerDelegate,FSMusicControllerDelegate, FSPublisherServerDelegate, FSUploadImageServerDelegate, FSShortVideoRecorderManagerDelegate, FSChallengeControllerDelegate>
{
    FSUploader *_uploader;
    NSString *_outPutPath;
    
    CGFloat _fxPosition;
    CGFloat _scoreVolume;
    CGFloat _soundtrackVolume;
    FSPublishOperationType _OperationType;
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

@property (nonatomic, assign)BOOL converted;
@property (nonatomic, assign)FSVideoFxType currentFxType;

@property (nonatomic, strong) FSPublisherServer *publishServer;
@property (nonatomic, strong) FSUploadImageServer *uploadImageServer;

@property (nonatomic, copy) NSString *videoDescription;
@property (nonatomic, assign) BOOL isSaved;

@property (nonatomic, copy) NSString *firstImageUrl;
@property (nonatomic, copy) NSString *webpUrl;

@property (nonatomic, strong) FSChallengeModel *challengeModel;

@end

@implementation FSPublisherController

-(NSMutableArray *)addedViews{
    if (!_addedViews) {
        _addedViews = [NSMutableArray array];
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
    _videoDescription = @"";
    
    
    [[FSDraftManager sharedManager] draftInfoWithPreInfo:_draftInfo];
    
    NSString *verifySdkLicenseFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"198-14-967dfb58745c59c1c409616af7ca27b3.lic"];
    
    [NvsStreamingContext verifySdkLicenseFile:verifySdkLicenseFilePath];
    _context = [NvsStreamingContext sharedInstance];
    if (!_timeLine) {
        NvsVideoResolution videoEditRes;
        videoEditRes.imageWidth = 1200;
        videoEditRes.imageHeight = 720;
        videoEditRes.imagePAR = (NvsRational){1, 1};
        NvsRational videoFps = {25, 1};
        NvsAudioResolution audioEditRes;
        audioEditRes.sampleRate = 48000;
        audioEditRes.channelCount = 2;
        audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
        _timeLine = [_context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes];
       NvsVideoTrack *videotrack = [_timeLine appendVideoTrack];
        [videotrack appendClip:_draftInfo.vFinalPath];
        
    }
    _videoTrack = [_timeLine getVideoTrackByIndex:0];
    
    
    NSString *_musicPath = _draftInfo.vMusic.mPath;
    NvsVideoClip *clip = [_videoTrack getClipWithIndex:0];
    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
    [clip setVolumeGain:_musicPath?0:1 rightVolumeGain:_musicPath?0:1];
    

    FSFileSliceDivider *divider = [[FSFileSliceDivider alloc] initWithSliceCount:1];
     _uploader = [FSUploader uploaderWithDivider:divider];
    [_uploader setDelegate:self];
    
    if (_draftInfo.vMusicVolume == -1 && _draftInfo.vOriginalVolume == -1) {
        if (_musicPath != nil && _musicPath.length > 0) {
            _scoreVolume = 0.5;
            _soundtrackVolume = -1;
            
            [[FSMusicPlayer sharedPlayer] setFilePath:_musicPath];
            [_toolView canEditMusic:YES];
        }
        else {
            _scoreVolume = 0.5;
            _soundtrackVolume = 0.5;
            
            [_toolView canEditMusic:NO];
        }
        
        _draftInfo.vMusicVolume = _scoreVolume;
        _draftInfo.vOriginalVolume = _soundtrackVolume;
    }
    else {
        _scoreVolume = _draftInfo.vMusicVolume;
        _soundtrackVolume = _draftInfo.vOriginalVolume;
        if (_musicPath != nil && _musicPath.length > 0) {
            [_toolView canEditMusic:YES];
        }
        else {
            [_toolView canEditMusic:NO];
        }
    }
    
    
    [self changeVolume];
    
    
}
-(void)playVideoFromHead{
    [_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster];
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Playback){
        int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
        if(![_context playbackTimeline:_timeLine startTime:startTime endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:NO flags:0]) {
        }
    }
    
    NSString *_musicPath = _draftInfo.vMusic.mPath;

    if (_musicPath != nil && _musicPath.length > 0 && !_isEnterCutMusicView) {
        [[FSMusicPlayer sharedPlayer] stop];
        NSTimeInterval _musicStartTime = _draftInfo.vMusic.mInPoint;
        [[FSMusicPlayer sharedPlayer] playAtTime:_musicStartTime];
        [[FSMusicPlayer sharedPlayer] play];
    }
    [self changeVolume];
}

- (void)changeVolume {
    [[FSMusicPlayer sharedPlayer] changeVolume:_scoreVolume];
    
    NvsVideoTrack *videoTrack = [_timeLine getVideoTrackByIndex:0];
    NvsVideoClip *videoClip = [videoTrack getClipWithIndex:0];
    [videoClip setVolumeGain:_soundtrackVolume rightVolumeGain:_soundtrackVolume];
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

    if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
        [[FSMusicPlayer sharedPlayer] stop];
    }
    
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
            return;
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
    NSString *_musicPath = _draftInfo.vMusic.mPath;
    if (_musicPath != nil && _musicPath.length > 0) {
        NvsAudioTrack *_audiotrack = [_timeLine appendAudioTrack];
        NvsAudioClip *audio = [_audiotrack appendClip:_musicPath];
        int64_t _musicStartTime = _draftInfo.vMusic.mInPoint;
        [audio changeTrimInPoint:_musicStartTime affectSibling:YES];
        [audio changeTrimOutPoint:length+_musicStartTime affectSibling:YES];
    }

    _outPutPath = [self getCompilePath];
    [self deleteCurrentCompileFile:_outPutPath];

    if([_context compileTimeline:_timeLine startTime:0 endTime:self.timeLine.duration outputFilePath:_outPutPath videoResolutionGrade:(NvsCompileVideoResolutionGrade720) videoBitrateGrade:(NvsCompileBitrateGradeLow) flags:0]){
        NSLog(@"11111111");
    }
    else {
        NSLog(@"0000000");
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
    UIImage *image = [[FSShortVideoRecorderManager sharedInstance] getImageFromFile:_outPutPath atTime:0 videoFrameHeightGrade:NvsVideoFrameHeightGrade480];
    
    if (_OperationType == FSPublishOperationTypePublishToNet) {
        [self uploadFirstImage:image];
    }else if(_OperationType == FSPublishOperationTypeSaveToDraft){
        
        NSString *imagePath = [FSDraftFileManager saveImageTolocal:image];
        
        [FSDraftManager sharedManager].tempInfo.vFinalPath = _outPutPath;
        [FSDraftManager sharedManager].tempInfo.vFirstFramePath = imagePath;
        [FSDraftManager sharedManager].tempInfo.vSaveToAlbum = _isSaved;
        
        // test
        FSDraftChallenge *challenge = [[FSDraftChallenge alloc] init];
        challenge.challengeDetail = @"challegeDatail";
        challenge.challengeName = @"challengeName";
        [FSDraftManager sharedManager].tempInfo.challenge = challenge;
        [FSDraftManager sharedManager].tempInfo.vTitle = _videoDescription;
        [FSDraftManager sharedManager].tempInfo.vMusicVolume = _scoreVolume;
        [FSDraftManager sharedManager].tempInfo.vOriginalVolume = _soundtrackVolume;
        
        [[FSDraftManager sharedManager] mergeInfo];
        [[FSDraftManager sharedManager] saveToLocal];
        [[FSDraftManager sharedManager] cancleOperate];
        
        [self.loading loadingViewShow];
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    if (_isSaved) {
        UISaveVideoAtPathToSavedPhotosAlbum(_outPutPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
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
    _draftInfo.challenge = draftChallenge;
    
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
    
    if (_draftInfo.vType == FSDraftInfoTypeVideo) {
        
        // 弹出提示
        UIAlertController *alertControlelr = [UIAlertController alertControllerWithTitle:@"" message:@"旧版本的不可编辑或者使用" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"cancle" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确认" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
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
        UIAlertController *alertControlelr = [UIAlertController alertControllerWithTitle:@"" message:@"返回编辑界面将清空所有特效信息" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"cancle" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确认" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
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
    
    NSString *_musicPath = _draftInfo.vMusic.mPath;
    if (_musicPath !=nil && _musicPath.length > 0) {
        _isEnterCutMusicView = YES;
        
        if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
            [[FSMusicPlayer sharedPlayer] stop];
        }
        
        if (!_cutMusicView) {
            NSTimeInterval _musicStartTime = _draftInfo.vMusic.mInPoint;
            _cutMusicView = [[FSCutMusicView alloc] initWithFrame:self.view.bounds filePath:_musicPath startTime:_musicStartTime];
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

    [[FSMusicPlayer sharedPlayer] stop];
    
    FSVideoFxController *fxController = [[FSVideoFxController alloc] init];
    fxController.timeLine = _timeLine;
    fxController.filePath = _draftInfo.vFinalPath;
    fxController.musicAttime = _draftInfo.vMusic.mInPoint;
    fxController.musicUrl = _draftInfo.vMusic.mPath;
    fxController.delegate = self;
    fxController.convertFilePath = _draftInfo.vConvertPath;
    
    //
    fxController.addedViews = self.addedViews;
    fxController.currentFxType = _currentFxType;
    fxController.convert = _converted;
    fxController.position = _fxPosition;
    
    _fxOperationStack = _fxOperationStack?:[FSVideoFxOperationStack new];
    fxController.fxOperationStack = _fxOperationStack;
    
    [self presentViewController:fxController animated:YES completion:nil];
}

- (void)FSPublisherToolViewAddFilter {
    [self chooseFilter];
}

- (void)FSPublisherToolViewEditVolume {
    if (!_volumeView) {
        _volumeView = [[FSControlVolumeView alloc] initWithFrame:self.view.bounds scroe:_scoreVolume soundtrack:_soundtrackVolume];
        _volumeView.delegate = self;
        [self.view addSubview:_volumeView];
        _volumeView.hidden = YES;
    }
    self.toolView.hidden = YES;
    _volumeView.hidden = NO;
    
}

- (void)FSPublisherToolViewChooseMusic {
    FSMusicController *music = [FSMusicController new];
    music.timeLine = _timeLine;
    music.pushed = YES;
    [music setDelegate:self];
    
    [self presentViewController:music animated:YES completion:nil];
}

- (void)FSPublisherToolViewSaveToDraft {
    //#warning 区分正序倒序，重复监测
    //UISaveVideoAtPathToSavedPhotosAlbum(_filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    _OperationType = FSPublishOperationTypeSaveToDraft;
    
    [self publishFiles];
}

- (void)FSPublisherToolViewSaveToLibrary:(BOOL)isSave {
    _isSaved = isSave;
}

- (void)FSPublisherToolViewChangeVideoDescription:(NSString *)description {
    _videoDescription = description;
}

#pragma mark - 
-(void)musicControllerSelectMusic:(NSString *)music musicId:(NSInteger)musicId{
    if (music != nil && music.length > 0) {
        _soundtrackVolume = -1;
        [self changeVolume];
        [_toolView canEditMusic:YES];
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
            //[videoClip appendPackagedFx:_videoFxPackageId];     // 追加包裹特效
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
    _scoreVolume = value;
    _draftInfo.vMusicVolume = value;
    [self changeVolume];
}

- (void)FSControlVolumeViewChangeSoundtrack:(CGFloat)value {
    _soundtrackVolume = value;
    _draftInfo.vOriginalVolume = value;
    [self changeVolume];
}

- (void)FSControlVolumeViewChangeFinished {
    _volumeView.hidden = YES;
    [_volumeView removeFromSuperview];
    _volumeView.delegate = nil;
    _volumeView = nil;
    self.toolView.hidden = NO;
}
- (void)FSCutMusicViewFinishCutMusicWithTime:(NSTimeInterval)newStartTime {
    _draftInfo.vMusic.mInPoint = newStartTime;
    _isEnterCutMusicView = NO;
    
    [self playVideoFromHead];

    _cutMusicView.hidden = YES;
    [_cutMusicView removeFromSuperview];
    _cutMusicView = nil;
    
    self.toolView.hidden = NO;
}
#pragma mark - 
-(void)videoFxControllerSaved:(NSArray *)addedViews
                       fxType:(FSVideoFxType)type
                     position:(CGFloat)position
                      convert:(BOOL)convert{
    
    [self.addedViews removeAllObjects];
    [self.addedViews addObjectsFromArray:addedViews];
    _currentFxType = type;
    _fxPosition = position;
    _converted = convert;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

- (NSString *)getNameFromPath:(NSString *)path {
    NSArray *array = [path componentsSeparatedByString:@"/"];
    NSString *name = [array lastObject];
    NSArray *nameArray = [name componentsSeparatedByString:@"."];
    return [nameArray firstObject];
}

- (void)uploadFirstImage:(UIImage *)image {
    if (!_uploadImageServer) {
        _uploadImageServer = [[FSUploadImageServer alloc] init];
        _uploadImageServer.delegate = self;
    }
   // UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);

    NSData * imageData = UIImageJPEGRepresentation(image,1);
    
    CGFloat length = [imageData length]/1000;
    CGFloat bit = 1;
    if (length > 200) {
        bit = 200/length;
    }
    [_uploadImageServer uploadFirstImage:[NSDictionary dictionaryWithObjectsAndKeys:UIImageJPEGRepresentation(image,bit),@"imageData",[self getNameFromPath:_outPutPath],@"imageName",nil]];
}

- (void)FSUploadImageServerFirstImageSucceed:(NSString *)filePath {
    _firstImageUrl = filePath;
    [self uploadFile:_outPutPath];

//    [[FSShortVideoRecorderManager sharedInstance] setDelegate:self];
//    [[FSShortVideoRecorderManager sharedInstance] beginCreateWebP:_outPutPath];
}

- (void)FSUploadImageServerFirstImageFailed:(NSError *)error {
    [self.loading loadingViewhide];
    
    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadFailed"]];
}

- (void)FSUploadImageServerWebPSucceed:(NSString *)filePath {
    _webpUrl = filePath;
    [self uploadFile:_outPutPath];
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
    UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    NSData *data = [NSData dataWithContentsOfFile:filePath];
   
    CGFloat length = [data length]/1000;
    CGFloat bit = 1;
    if (length > 200) {
        bit = 200/length;
    }
    [_uploadImageServer uploadWebP:[NSDictionary dictionaryWithObjectsAndKeys:data,@"webpData",[self getNameFromPath:_outPutPath],@"webpName",nil]];
}

- (void)FSShortVideoRecorderManagerConvertorFaild {
    [self.loading loadingViewhide];
    
    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadFailed"]];
}

#pragma mark -
- (void)uploadFile:(NSString *)filePath{
//    NSLog(@"filePath %@",filePath);
    __block FSPublisherController *weakSelf = self;
    [_uploader uploadFileWithFilePath:filePath complete:^(CGFloat progress, NSString *filePath, NSDictionary * info) {
        
        if(!info){
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.loading loadingViewhide];
                [weakSelf showMessage:NSLocalizedString(@"UploadFailed", nil)];
            });
            return ;
        }
        
        
        NSLog(@"uploadFile: %f  %@",progress,filePath);
        if (!_publishServer) {
            _publishServer = [[FSPublisherServer alloc] init];
            _publishServer.delegate = weakSelf;
        }
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"loginKey"] forKey:@"loginKey"];
        [dic setValue:[NSNumber numberWithInt:4] forKey:@"requestType"];
        [dic setValue:[info objectForKey:@"dataInfo"] forKey:@"vu"];
        [dic setValue:weakSelf.videoDescription forKey:@"vd"]; //
        [dic setValue:_firstImageUrl forKey:@"vp"];    //image
        [dic setValue:_webpUrl forKey:@"vg"];   //webp
        [dic setValue:@([[FSDraftManager  sharedManager] tempInfo].vMusic.mId) forKey:@"si"]; //歌曲id
        [dic setValue:@([[FSDraftManager  sharedManager] tempInfo].challenge.challengeId) forKey:@"di"];  //挑战ID
        [dic setValue:[NSArray array] forKey:@"a"];  //消息[{"ui":12815,"nk":"tttty"},{"ui":90665,"nk":"ytest"}]
//        [dic setValue:@"被@用户ID" forKey:@"ui"];
//        [dic setValue:@"用户昵称" forKey:@"nk"];
        
        [_publishServer publisherVideo:dic];
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

    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadSecceed"]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)FSPublisherServerFailed:(NSError *)error {
    [self.loading loadingViewhide];

    [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadFailed"]];
}

- (void)showMessage:(NSString *)message {
    FSAlertView *alertView = [[FSAlertView alloc] init];
    [alertView showWithMessage:message];
}


@end
