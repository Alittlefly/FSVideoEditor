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

@interface FSPublisherController ()<NvsStreamingContextDelegate,UINavigationControllerDelegate,FSPublisherToolViewDelegate,FSFilterViewDelegate,FSUploaderDelegate, FSControlVolumeViewDelegate, FSCutMusicViewDelegate,FSVideoFxControllerDelegate,FSMusicControllerDelegate, FSPublisherServerDelegate>
{
    FSUploader *_uploader;
    NSString *_outPutPath;
    
    int64_t _startTime;
    int64_t _endTime;
    
    CGFloat _fxPosition;
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
-(void)setTrimIn:(int64_t)trimIn{
    _trimIn = trimIn;
    _startTime = trimIn;
}
-(void)setTrimOut:(int64_t)trimOut{
    _trimOut = trimOut;
    _endTime = trimOut;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    // Do any additional setup after loading the view.
    _prewidow = [[NvsLiveWindow alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_prewidow];
    
    _isEnterCutMusicView = NO;
    
    if (!_filePath) {
        return;
    }
    NSString *verifySdkLicenseFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"198-14-fecf5c838a33c8b7a27de9790aa3fa96.lic"];
    
    [NvsStreamingContext verifySdkLicenseFile:verifySdkLicenseFilePath];
    _context = [NvsStreamingContext sharedInstance];
    if (!_timeLine) {
        return;
    }
    _videoTrack = [_timeLine getVideoTrackByIndex:0];
    
    NvsVideoClip *clip = [_videoTrack getClipWithIndex:0];
    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
    [clip setVolumeGain:_musicPath?0:1 rightVolumeGain:_musicPath?0:1];
    
    _toolView = [[FSPublisherToolView alloc] initWithFrame:self.view.bounds];
    _toolView.backgroundColor = [UIColor clearColor];
    _toolView.delegate =self;
    [self.view addSubview:_toolView];
    
    FSFileSliceDivider *divider = [[FSFileSliceDivider alloc] initWithSliceCount:1];
     _uploader = [FSUploader uploaderWithDivider:divider];
    [_uploader setDelegate:self];
    
    if (_musicPath != nil && _musicPath.length > 0) {
        [[FSMusicPlayer sharedPlayer] setFilePath:_musicPath];
        [_toolView canEditMusic:YES];
    }
    else {
        [_toolView canEditMusic:NO];
    }
 
}
-(void)playVideoFromHead{
    [_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster];
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Playback){
        int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
        if(![_context playbackTimeline:_timeLine startTime:startTime endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:NO flags:0]) {
        }
    }
    
    if (_musicPath != nil && _musicPath.length > 0 && !_isEnterCutMusicView) {
        [[FSMusicPlayer sharedPlayer] stop];
        [[FSMusicPlayer sharedPlayer] playAtTime:_musicStartTime];
        [[FSMusicPlayer sharedPlayer] play];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    
    if (_musicPath != nil && _musicPath.length > 0) {
        NvsAudioTrack *_audiotrack = [_timeLine appendAudioTrack];
        NvsAudioClip *audio = [_audiotrack appendClip:_musicPath];
        [audio changeTrimInPoint:_musicStartTime affectSibling:YES];
        [audio changeTrimOutPoint:length+_musicStartTime affectSibling:YES];
    }

    _outPutPath = [self getCompilePath];

    [self deleteCurrentCompileFile:_outPutPath];

    if([_context compileTimeline:_timeLine startTime:0 endTime:self.timeLine.duration outputFilePath:_outPutPath videoResolutionGrade:(NvsCompileVideoResolutionGrade2160) videoBitrateGrade:(NvsCompileBitrateGradeHigh) flags:0]){
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
    
    [self.loading loadingViewhide];
    [self uploadFile:_outPutPath];
  //  UISaveVideoAtPathToSavedPhotosAlbum(_outPutPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);

}
// 生成失败的回调函数
- (void)didCompileFailed:(NvsTimeline *)timeline {
    NSLog(@"Compile Failed!");
    
    [self.loading loadingViewhide];

}
#pragma mark - FSPublisherToolViewDelegate
- (void)FSPublisherToolViewPublished {
    [self publishFiles];
}
- (void)FSPublisherToolViewQuit {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)FSPublisherToolViewEditMusic {
    if (_musicPath !=nil && _musicPath.length > 0) {
        _isEnterCutMusicView = YES;
        
        if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
            [[FSMusicPlayer sharedPlayer] stop];
        }
        
        if (!_cutMusicView) {
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
    fxController.filePath = _filePath;
    fxController.musicAttime = _musicStartTime?:0;
    fxController.musicUrl = _musicPath?:nil;
    fxController.delegate = self;
    fxController.convertFilePath = _convertFilePath;
    
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
        _volumeView = [[FSControlVolumeView alloc] initWithFrame:self.view.bounds];
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
#warning 区分正序倒序，重复监测
    //UISaveVideoAtPathToSavedPhotosAlbum(_filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark - 
-(void)musicControllerSelectMusic:(NSString *)music{
    if (music != nil && music.length > 0) {
        [_toolView canEditMusic:YES];
        _musicPath = music;
        _musicStartTime = 0;
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
    [self seekTimeline];
}

- (void)seekTimeline {

    if (![_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster])
        NSLog(@"Failed to seek timeline!");
    [self playVideoFromHead];
}

#pragma mark - FSControlVolumeViewDelegate
- (void)FSControlVolumeViewChangeScore:(CGFloat)value {
    NvsAudioTrack *audioTrack = [_timeLine getAudioTrackByIndex:0];
    NvsAudioClip *audioClip = [audioTrack getClipWithIndex:0];
    [audioClip setVolumeGain:value rightVolumeGain:value];
}

- (void)FSControlVolumeViewChangeSoundtrack:(CGFloat)value {
    NvsVideoTrack *videoTrack = [_timeLine getVideoTrackByIndex:0];
    NvsVideoClip *videoClip = [videoTrack getClipWithIndex:0];
    [videoClip setVolumeGain:value rightVolumeGain:value];
}

- (void)FSControlVolumeViewChangeFinished {
    _volumeView.hidden = YES;
    self.toolView.hidden = NO;
}
- (void)FSCutMusicViewFinishCutMusicWithTime:(NSTimeInterval)newStartTime {
    _musicStartTime = newStartTime;
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

#pragma mark -
- (void)uploadFile:(NSString *)filePath{
//    NSLog(@"filePath %@",filePath);
    __block FSPublisherController *weakSelf = self;
    [_uploader uploadFileWithFilePath:filePath complete:^(CGFloat progress, NSString *filePath, id info) {
        NSLog(@"uploadFile: %f  %@",progress,filePath);
        if (!_publishServer) {
            _publishServer = [[FSPublisherServer alloc] init];
            _publishServer.delegate = weakSelf;
        }
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"loginKey"] forKey:@"loginKey"];
        [dic setValue:[NSNumber numberWithInt:4] forKey:@"requestType"];
        [dic setValue:[info objectForKey:@"dataInfo"] forKey:@"vu"];
        [dic setValue:@"视频描述" forKey:@"vd"];
        [dic setValue:@"视频图片" forKey:@"vp"];
        [dic setValue:@"视频动态图" forKey:@"vg"];
        [dic setValue:[NSNumber numberWithInt:1111] forKey:@"si"]; //歌曲id
        [dic setValue:[NSNumber numberWithInt:2222] forKey:@"di"];  //挑战ID
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
    [self showMessage:NSLocalizedString(@"UploadSecceed", nil)];
}

- (void)FSPublisherServerFailed:(NSError *)error {
    [self showMessage:NSLocalizedString(@"UploadFailed", nil)];
}

- (void)showMessage:(NSString *)message {
    FSAlertView *alertView = [[FSAlertView alloc] init];
    [alertView showWithMessage:message];
}


@end
