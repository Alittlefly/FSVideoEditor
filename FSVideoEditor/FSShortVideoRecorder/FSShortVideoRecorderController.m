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

@interface FSShortVideoRecorderController ()<FSShortVideoRecorderViewDelegate>

@property (nonatomic, strong) FSShortVideoRecorderView *recorderView;

@end

@implementation FSShortVideoRecorderController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _recorderView = [[FSShortVideoRecorderView alloc] initWithFrame:self.view.bounds];
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
    [self.navigationController popViewControllerAnimated:YES];

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
    //publish.convertFilePath = convertFilePath;
    publish.playSpeed = speed;
    publish.musicPath = _musicFilePath;
    publish.musicStartTime = time;
    NvsTimeline *timeLine = [[FSShortVideoRecorderManager sharedInstance] createTimeLine];
    NvsVideoTrack *videoTrack = [timeLine appendVideoTrack];
    NvsVideoClip *clip = [videoTrack insertClip:filePath clipIndex:0];
    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
    publish.timeLine = timeLine;
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
