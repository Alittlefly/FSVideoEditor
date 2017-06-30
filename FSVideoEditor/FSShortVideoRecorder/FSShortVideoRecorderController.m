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

- (void)dealloc {
    //_recorderView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[FSShortVideoRecorderManager sharedInstance] initBaseData];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];
    
//    if([[FSShortVideoRecorderManager sharedInstance] getStreamingEngineState] != NvsStreamingEngineState_Stopped)
//        [_context stop];
//    [_context setDelegate:nil];

}

#pragma mark - FSShortVideoRecorderViewDelegate

- (void)FSShortVideoRecorderViewQuitRecorderView {
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)FSShortVideoRecorderViewFinishRecorder:(NSString *)filePath {
    FSPublisherController *publish = [[FSPublisherController alloc] init];
    publish.filePath = filePath;
    NvsTimeline *timeLine = [[FSShortVideoRecorderManager sharedInstance] createTimeLine];
    NvsVideoTrack *videoTrack = [timeLine appendVideoTrack];
    NvsVideoClip *clip = [videoTrack insertClip:filePath clipIndex:0];
    [clip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
    publish.timeLine = timeLine;
    [self.navigationController pushViewController:publish animated:YES];
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
