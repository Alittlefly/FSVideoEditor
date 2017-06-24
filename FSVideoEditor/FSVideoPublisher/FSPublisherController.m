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
#import "FSPublisherToolView.h"
#import "FSPublishView.h"
#import "FSFilterView.h"


@interface FSPublisherController ()<NvsStreamingContextDelegate,UINavigationControllerDelegate,FSPublisherToolViewDelegate,FSPublishViewDelegate,FSFilterViewDelegate>
@property(nonatomic,strong)NvsLiveWindow *prewidow;
@property(nonatomic,assign)NvsStreamingContext*context;
@property(nonatomic,assign)NvsTimeline   *timeLine;
@property(nonatomic,assign)NvsVideoTrack *videoTrack;

@property (nonatomic, strong) FSPublisherToolView *toolView;
@property(nonatomic,strong)FSPublishView *publishContent;

@property (nonatomic, strong) FSFilterView *filterView;


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
    
    _toolView = [[FSPublisherToolView alloc] initWithFrame:self.view.bounds];
    _toolView.backgroundColor = [UIColor clearColor];
    _toolView.delegate =self;
    [self.view addSubview:_toolView];
 
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Stopped)
        [_context stop];
    [_context setDelegate:nil];
    
    [self.navigationController.navigationBar setHidden:NO];

}
#pragma mark -
-(void)didPlaybackEOF:(NvsTimeline *)timeline{
    [_context seekTimeline:timeline timestamp:0 videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster];
    if(![_context playbackTimeline:_timeLine startTime:0 endTime:_timeLine.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:NO flags:0]) {
    }
}

#pragma mark - FSPublisherToolViewDelegate
- (void)FSPublisherToolViewPublished {

}

- (void)FSPublisherToolViewQuit {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)FSPublisherToolViewEditMusic {

}

- (void)FSPublisherToolViewAddEffects {
    self.toolView.hidden = YES;
    
    if (!_filterView) {
        _filterView = [[FSFilterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-120, self.view.frame.size.width, 120)];
        _filterView.backgroundColor = [UIColor clearColor];
        _filterView.hidden = YES;
        [self.view addSubview:_filterView];
    }
    
    _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.view.frame.size.height, _filterView.frame.size.width, _filterView.frame.size.height);
    _filterView.hidden = NO;
    [UIView animateWithDuration:1 animations:^{
        _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.view.frame.size.height-_filterView.frame.size.height, _filterView.frame.size.width, _filterView.frame.size.height);

    }];
}

- (void)FSPublisherToolViewEditVolume {

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

- (void)FSFilterViewChooseFilter:(id)filter {

}

#pragma mark -
-(void)publishViewClickVideoFx:(FSPublishView *)publish{
    FSVideoFxController *fxController = [[FSVideoFxController alloc] init];
    fxController.timeLine = _timeLine;
    fxController.filePath = _filePath;
    [self.navigationController pushViewController:fxController animated:YES];
}

-(void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}
@end
