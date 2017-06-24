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
#import "FSPublishView.h"
@interface FSPublisherController ()<NvsStreamingContextDelegate,UINavigationControllerDelegate,FSPublishViewDelegate>
@property(nonatomic,strong)NvsLiveWindow *prewidow;
@property(nonatomic,assign)NvsStreamingContext*context;
@property(nonatomic,assign)NvsTimeline   *timeLine;
@property(nonatomic,assign)NvsVideoTrack *videoTrack;
@property(nonatomic,strong)FSPublishView *publishContent;
@end

@implementation FSPublisherController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _prewidow = [[NvsLiveWindow alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_prewidow];
    
    _publishContent = [[FSPublishView alloc] initWithFrame:self.view.bounds];
    [_publishContent setDelegate:self];
    [self.view addSubview:_publishContent];
    
    if (!_filePath) {
        return;
    }
     _context = [NvsStreamingContext sharedInstance];
    [_context setDelegate:self];
    
    NvsVideoResolution res;
    res.imageWidth = 1200;
    res.imageHeight = 700;
    res.imagePAR = (NvsRational){1,1};
    
    NvsRational videoFps = {25, 1};
    NvsAudioResolution audioEditRes;
    audioEditRes.sampleRate = 48000;
    audioEditRes.channelCount = 2;
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
    
     _timeLine = [_context createTimeline:&res videoFps:&videoFps audioEditRes:&audioEditRes];
     _videoTrack = [_timeLine appendVideoTrack];
    NvsVideoClip *clip = [_videoTrack insertClip:_filePath clipIndex:0];
    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
    [_context connectTimeline:_timeLine withLiveWindow:_prewidow];
    [_context seekTimeline:_timeLine timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster];
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Playback){
        int64_t startTime = [_context getTimelineCurrentPosition:_timeLine];
        if(![_context playbackTimeline:_timeLine startTime:startTime endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:NO flags:0]) {
        }
    }
 
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Stopped)
        [_context stop];
    [_context setDelegate:nil];
}
#pragma mark -
-(void)didPlaybackEOF:(NvsTimeline *)timeline{
    [_context seekTimeline:timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster];
    if(![_context playbackTimeline:_timeLine startTime:0 endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:NO flags:0]) {
    }
}
#pragma mark - 
-(void)publishViewClickVideoFx:(FSPublishView *)publish{
    FSVideoFxController *fxController = [[FSVideoFxController alloc] init];
    fxController.timeLine = _timeLine;
    [self.navigationController pushViewController:fxController animated:YES];
}
-(void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}
@end
