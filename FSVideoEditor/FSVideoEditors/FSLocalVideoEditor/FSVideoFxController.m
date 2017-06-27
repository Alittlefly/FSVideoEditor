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
#import "NvsVideoClip.h"
#import "NvsThumbnailSequenceView.h"
#import "FSVideoFxView.h"

@interface FSVideoFxController ()<NvsStreamingContextDelegate,FSVideoFxViewDelegate>
{
    NSMutableString *_videoFxPackageId;
}
@property(nonatomic,strong)NvsLiveWindow *prewidow;
@property(nonatomic,assign)NvsStreamingContext*context;
@property(nonatomic,assign)NvsVideoTrack *videoTrack;
@property(nonatomic,strong)FSVideoFxView *videoFxView;
@end

@implementation FSVideoFxController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self creatSubViews];
    
     _context = [NvsStreamingContext sharedInstance];

    NSString *SoulfxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"C6273A8F-C899-4765-8BFC-E683EE37AA84.videofx"];
    NSString *ScalefxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"A8A4344D-45DA-460F-A18F-C0E2355FE864.videofx"];
    
    [_context.assetPackageManager installAssetPackage:SoulfxPath license:nil type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:nil];
    [_context.assetPackageManager installAssetPackage:ScalefxPath license:nil type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:nil];
    
    _prewidow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(82, 54, 210, 373)];
    [self.view addSubview:_prewidow];
    
    NSArray *fxs = [_context.assetPackageManager getAssetPackageListOfType:(NvsAssetPackageType_VideoFx)];

    if (!_timeLine) {
        return;
    }
    
    _videoFxView = [[FSVideoFxView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_prewidow.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(_prewidow.frame)) fxs:fxs];
    [_videoFxView setDelegate:self];
    [self.view addSubview:_videoFxView];
    _videoFxView.duration = _timeLine.duration/1000000.0;
    
     _videoTrack = [_timeLine getVideoTrackByIndex:0];
    [_context connectTimeline:_timeLine withLiveWindow:_prewidow];
    
    
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
-(void)playVideoFromHead{
    if (![_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster]){
        NSLog(@"Failed to seek timeline!");
    }
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Playback){
        int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
        if(![_context playbackTimeline:_timeLine startTime:startTime endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:NO flags:0]) {
        }
        
        [_videoFxView start];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_context setDelegate:self];
    
    [self playVideoFromHead];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Stopped)
        [_context stop];
    [_context setDelegate:nil];
    [_videoFxView stop];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)save{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma make -
-(void)didPlaybackEOF:(NvsTimeline *)timeline{
    [self playVideoFromHead];
}
-(void)didPlaybackStopped:(NvsTimeline *)timeline{

}
#pragma mark -
-(void)videoFxViewSelectTimeFx:(FSVideoFxType)type{
    if (type == FSVideoFxTypeSlow) {
        //缓慢
        int64_t point = _timeLine.duration * 0.5;
        NvsVideoClip *videoClip = [_videoTrack getClipWithTimelinePosition:point];
        [videoClip changeSpeed:0.5];
        
    }else if(type == FSVideoFxTypeRepeat){
        // 重复
        int64_t point = _timeLine.duration * 0.5;
        
        [_videoTrack addClip:_filePath inPoint:point trimIn:0 trimOut:_timeLine.duration*0.01];
        [_videoTrack addClip:_filePath inPoint:point trimIn:0 trimOut:_timeLine.duration*0.01];
    }else if (type == FSVideoFxTypeRevert){
        // 倒序播放
    }
    
    [self playVideoFromHead];
}
-(void)videoFxViewSelectFxPackageId:(NSString *)fxId{
    NvsVideoClip *videoClip = [_videoTrack getClipWithIndex:0];
    [videoClip removeAllFx];
    [videoClip appendPackagedFx:fxId];
    
    [self playVideoFromHead];
}
-(CGFloat)videoFxViewUpdateProgress{
    
    int64_t current = [_context getTimelineCurrentPosition:_timeLine];
    CGFloat progress = (CGFloat)current/_timeLine.duration;
    return progress;
}


-(void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

@end
