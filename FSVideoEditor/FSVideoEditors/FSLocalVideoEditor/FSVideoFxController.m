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
@property(nonatomic,strong)NvsThumbnailSequenceView *thumbnailSequence;
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
    [_context setDelegate:self];

    NSString *SoulfxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"C6273A8F-C899-4765-8BFC-E683EE37AA84.videofx"];
    NSString *ScalefxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"A8A4344D-45DA-460F-A18F-C0E2355FE864.videofx"];
    
    [_context.assetPackageManager installAssetPackage:SoulfxPath license:nil type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:nil];
    [_context.assetPackageManager installAssetPackage:ScalefxPath license:nil type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:nil];
    
    _prewidow = [[NvsLiveWindow alloc] initWithFrame:CGRectMake(82, 54, 210, 373)];
    [self.view addSubview:_prewidow];
    
    NSArray *fxs = [_context.assetPackageManager getAssetPackageListOfType:(NvsAssetPackageType_VideoFx)];
    
    _videoFxView = [[FSVideoFxView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_prewidow.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(_prewidow.frame)) fxs:fxs];
    [self.view addSubview:_videoFxView];
    
    if (!_timeLine) {
        return;
    }
     _videoTrack = [_timeLine getVideoTrackByIndex:0];
    [_context connectTimeline:_timeLine withLiveWindow:_prewidow];
    
    NvsVideoClip *videoClip = [_videoTrack getClipWithIndex:0];
    [videoClip removeAllFx];
    [videoClip appendPackagedFx:[_context.assetPackageManager getAssetPackageIdFromAssetPackageFilePath:ScalefxPath]];
    
//    if (!_thumbnailSequence) {
//        _thumbnailSequence = [[NvsThumbnailSequenceView alloc] init];
//        _thumbContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(self.view.bounds) - 70, CGRectGetWidth(self.view.bounds),60)];
//        [_thumbContent setBackgroundColor:[UIColor redColor]];
//        [_thumbContent addSubview:_thumbnailSequence];
//        [_thumbContent setContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 0)];
//        [self.view addSubview:_thumbContent];
//        
//    }
    
//    NvsVideoClip* clip = [_videoTrack insertClip:_filePath clipIndex:0];
//    [clip setSourceBackgroundMode:NvsSourceBackgroundModeColorSolid];
    
//    self.thumbnailSequence.stillImageHint = NO;
//    self.thumbnailSequence.mediaFilePath = _filePath;
//    self.thumbnailSequence.startTime = 0;
//    self.thumbnailSequence.duration = _timeLine.duration;
//    self.thumbnailSequence.thumbnailAspectRatio = 1.0;
//    [self.thumbnailSequence setFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.bounds), 60)];
//    [self.thumbnailSequence setClipsToBounds:NO];
    
    
    if (![_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster]){
        NSLog(@"Failed to seek timeline!");
    }
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Playback){
        int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
        if(![_context playbackTimeline:_timeLine startTime:startTime endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:0]) {
        }
    }
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Stopped)
        [_context stop];
    [_context setDelegate:nil];
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

-(void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

@end
