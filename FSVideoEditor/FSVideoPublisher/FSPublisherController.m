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
#import "NvsVideoFrameRetriever.h"


#import "FSPublisherToolView.h"
#import "FSFilterView.h"
#import "FSUploader.h"
#import "FSEditorLoading.h"
#import "FSControlVolumeView.h"

@interface FSPublisherController ()<NvsStreamingContextDelegate,UINavigationControllerDelegate,FSPublisherToolViewDelegate,FSFilterViewDelegate,FSUploaderDelegate, FSControlVolumeViewDelegate>
{
    FSUploader *_uploader;
    NSString *_outPutPath;

}
@property(nonatomic,strong)NvsLiveWindow *prewidow;
@property(nonatomic,assign)NvsStreamingContext*context;
@property(nonatomic,assign)NvsVideoTrack *videoTrack;

@property (nonatomic, strong) FSPublisherToolView *toolView;

@property (nonatomic, strong) FSFilterView *filterView;
@property(nonatomic,strong)FSEditorLoading *loading;
@property(nonatomic,strong)NvsVideoFrameRetriever *frameRetriever;

@property (nonatomic, strong) FSControlVolumeView *volumeView;


@end

@implementation FSPublisherController
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
    
    if (!_filePath) {
        return;
    }
    _context = [NvsStreamingContext sharedInstance];
    if (!_timeLine) {
        return;
    }
    _videoTrack = [_timeLine getVideoTrackByIndex:0];
    
    NvsVideoClip *clip = [_videoTrack getClipWithIndex:0];
    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
    
    _toolView = [[FSPublisherToolView alloc] initWithFrame:self.view.bounds];
    _toolView.backgroundColor = [UIColor clearColor];
    _toolView.delegate =self;
    [self.view addSubview:_toolView];
    
    FSFileSliceDivider *divider = [[FSFileSliceDivider alloc] initWithSliceCount:1];
     _uploader = [FSUploader uploaderWithDivider:divider];
    [_uploader setDelegate:self];
 
}
-(void)playVideoFromHead{
    [_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster];
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Playback){
        int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
        if(![_context playbackTimeline:_timeLine startTime:startTime endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:NO flags:0]) {
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_context connectTimeline:_timeLine withLiveWindow:_prewidow];
    [self.navigationController.navigationBar setHidden:YES];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_context setDelegate:self];
    [self playVideoFromHead];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];

}

-(void)vieDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Stopped)
        [_context stop];
    [_context setDelegate:nil];
    
    [self.navigationController.navigationBar setHidden:NO];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
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
    return [final stringByAppendingFormat:@"/video%@.mp4",timeRandom];
}
                             
                             

-(void)publishFiles{
    [self.navigationController.view addSubview:self.loading];
    [self.loading loadingViewShow];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    _outPutPath = [self getCompilePath];

    [self deleteCurrentCompileFile:_outPutPath];

    if([_context compileTimeline:_timeLine startTime:0 endTime:_timeLine.duration outputFilePath:_outPutPath videoResolutionGrade:(NvsCompileVideoResolutionGrade2160) videoBitrateGrade:(NvsCompileBitrateGradeHigh) flags:0]){
    }
}
#pragma mark -
-(void)didPlaybackEOF:(NvsTimeline *)timeline{
    [self playVideoFromHead];
}
// 生成完成的回调函数
- (void)didCompileFinished:(NvsTimeline *)timeline{
    
    NSLog(@"Compile success!");
//    _frameRetriever = [_context createVideoFrameRetriever:_outPutPath];
//    UIImage *firstFrame = [_frameRetriever getFrameAtTime:0 videoFrameHeightGrade:(NvsVideoFrameHeightGrade720)];
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:firstFrame];
//    [imageView setContentMode:(UIViewContentModeScaleAspectFill)];
//    [imageView setFrame:self.view.bounds];
//    [self.view addSubview:imageView];
    
    [self.loading loadingViewhide];
    [self uploadFile:_outPutPath];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

}
// 生成失败的回调函数
- (void)didCompileFailed:(NvsTimeline *)timeline {
    NSLog(@"Compile Failed!");
    
    [self.loading loadingViewhide];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

}
#pragma mark - FSPublisherToolViewDelegate
- (void)FSPublisherToolViewPublished {
    [self publishFiles];
}
- (void)FSPublisherToolViewQuit {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)FSPublisherToolViewEditMusic {

}

- (void)FSPublisherToolViewAddEffects {
    FSVideoFxController *fxController = [[FSVideoFxController alloc] init];
    fxController.timeLine = _timeLine;
    fxController.filePath = _filePath;
    [self.navigationController pushViewController:fxController animated:YES];
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

}

- (void)FSPublisherToolViewSaveToDraft {

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

}

#pragma mark - FSControlVolumeViewDelegate
- (void)FSControlVolumeViewChangeScore:(CGFloat)value {

}

- (void)FSControlVolumeViewChangeSoundtrack:(CGFloat)value {

}

- (void)FSControlVolumeViewChangeFinished {
    _volumeView.hidden = YES;
    self.toolView.hidden = NO;
}

#pragma mark -
- (void)uploadFile:(NSString *)filePath{
    NSLog(@"filePath %@",filePath);
    [_uploader uploadFileWithFilePath:filePath];
}
-(void)uploadUpFiles:(NSString *)filePath progress:(float)progress{
    NSLog(@"progress %.2f",progress);
}

-(void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}
@end
