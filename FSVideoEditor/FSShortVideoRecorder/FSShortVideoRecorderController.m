//
//  FSShortVideoRecorderController.m
//  7nujoom
//
//  Created by 王明 on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSShortVideoRecorderController.h"
#import "FSShortVideoRecorderView.h"
#import "FSPublisherController.h"
#import "FSShortVideoRecorderManager.h"
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"
#import "FSAlertView.h"
#import "FSFilterView.h"
#import "FSDraftManager.h"

@interface FSShortVideoRecorderController ()<FSShortVideoRecorderViewDelegate, FSFilterViewDelegate>
{
    FSDraftInfo *_tempInfo;
}

@property (nonatomic, strong) FSShortVideoRecorderView *recorderView;
@property (nonatomic, strong) FSFilterView *filterView;

@end

@implementation FSShortVideoRecorderController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tempInfo = [[FSDraftManager sharedManager] draftInfoWithPreInfo:_draftInfo];
//    _tempInfo.recordVideoTimeArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:3],[NSNumber numberWithFloat:1.5],[NSNumber numberWithFloat:5], nil];
//    _tempInfo.recordVideoSpeedArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithFloat:1],[NSNumber numberWithFloat:1], nil];
//    _tempInfo.recordVideoPathArray = [NSArray arrayWithObjects:@"111",@"222",@"333", nil];
    _recorderView = [[FSShortVideoRecorderView alloc] initWithFrame:self.view.bounds draftInfo:_tempInfo];
    _recorderView.delegate =self;
    [self.view addSubview:_recorderView];
    
    
}

- (void)backClik {
}

-(void)dealloc{
    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_recorderView resumeCapturePreview];
    if (_musicFilePath != nil && _musicFilePath.length > 0) {
        _recorderView.musicFilePath = _musicFilePath;
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
//    if([[FSShortVideoRecorderManager sharedInstance] getStreamingEngineState] != NvsStreamingEngineState_Stopped)
//        [_context stop];
//    [_context setDelegate:nil];

}

#pragma mark - FSShortVideoRecorderViewDelegate

- (void)FSShortVideoRecorderViewQuitRecorderView {
    if (_isPresented) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (void)FSShortVideoRecorderViewFinishRecorder:(NSString *)filePath speed:(CGFloat)speed musicStartTime:(NSTimeInterval)time {
//    FSPublisherController *publish = [[FSPublisherController alloc] init];
//    publish.filePath = filePath;
//    publish.playSpeed = speed;
//    publish.musicPath = _musicFilePath;
//    publish.musicStartTime = time;
//    NvsTimeline *timeLine = [[FSShortVideoRecorderManager sharedInstance] createTimeLine];
//    NvsVideoTrack *videoTrack = [timeLine appendVideoTrack];
//    NvsVideoClip *clip = [videoTrack insertClip:filePath clipIndex:0];
//    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
//    publish.timeLine = timeLine;
//    [self.navigationController pushViewController:publish animated:YES];
}

- (void)FSShortVideoRecorderViewFinishRecorder:(NSString *)filePath convertFilePath:(NSString *)convertFilePath speed:(CGFloat)speed musicStartTime:(NSTimeInterval)time {
    FSPublisherController *publish = [[FSPublisherController alloc] init];
    publish.filePath = filePath;
    publish.convertFilePath = convertFilePath;
    publish.playSpeed = speed;
    publish.musicPath = _musicFilePath;
    publish.musicStartTime = time;
    NvsTimeline *timeLine = [[FSShortVideoRecorderManager sharedInstance] createTimeLine];
    NvsVideoTrack *videoTrack = [timeLine appendVideoTrack];
    NvsVideoClip *clip = [videoTrack insertClip:filePath clipIndex:0];
    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
    publish.timeLine = timeLine;
    
    _tempInfo.vSpeed = speed;
    _tempInfo.vOriginalPath = filePath;
    _tempInfo.vConvertPath = convertFilePath;
    
    [[FSDraftManager sharedManager] mergeInfo];
    [[FSDraftManager sharedManager] clearInfo];
    
    [self.navigationController pushViewController:publish animated:YES];
}

- (void)FSShortVideoRecorderViewFinishTimeLine:(NvsTimeline *)timeLine speed:(CGFloat)speed musicStartTime:(NSTimeInterval)time {
    FSPublisherController *publish = [[FSPublisherController alloc] init];
    //publish.filePath = filePath;
    publish.playSpeed = speed;
    publish.musicPath = _musicFilePath;
    publish.musicStartTime = time;
//    NvsTimeline *timeLine = [[FSShortVideoRecorderManager sharedInstance] createTimeLine];
//    NvsVideoTrack *videoTrack = [timeLine appendVideoTrack];
//    NvsVideoClip *clip = [videoTrack insertClip:filePath clipIndex:0];
//    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
    publish.timeLine = timeLine;
    [self.navigationController pushViewController:publish animated:YES];
}

- (void)FSShortVideoRecorderViewShowAlertView:(NSString *)message {
    FSAlertView *alet = [[FSAlertView alloc] initWithFrame:self.view.bounds];
    [alet showWithMessage:message];
}

- (void)FSShortVideoRecorderViewShowFilterView {
    if (!_filterView) {
        _filterView = [[FSFilterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-120, self.view.frame.size.width, 120)];
        _filterView.backgroundColor = [UIColor clearColor];
        _filterView.hidden = YES;
        _filterView.delegate =self;
        [self.view addSubview:_filterView];
    }
    
    _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.view.frame.size.height, _filterView.frame.size.width, _filterView.frame.size.height);
    _filterView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.view.frame.size.height-_filterView.frame.size.height, _filterView.frame.size.width, _filterView.frame.size.height);
        
    }];
}

- (void)FSFilterViewChooseFilter:(NSString *)filter {
    [_recorderView changeFilter:filter];
}

- (void)FSFilterViewFinishedChooseFilter {
    [UIView animateWithDuration:0.5 animations:^{
        _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.view.frame.size.height, _filterView.frame.size.width, _filterView.frame.size.height);
        
    } completion:^(BOOL finished) {
        _filterView.hidden = YES;
        [_filterView removeFromSuperview];
        _filterView.delegate = nil;
        _filterView= nil;
        [_recorderView finishChangeFilter];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
