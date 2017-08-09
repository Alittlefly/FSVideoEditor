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
    [_tempInfo clearFxInfos];
    
    _recorderView = [[FSShortVideoRecorderView alloc] initWithFrame:self.view.bounds draftInfo:_tempInfo];
    _recorderView.draftInfo = _tempInfo;
    _recorderView.delegate =self;
    [self.view addSubview:_recorderView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_recorderView resumeCapturePreview];
    if (_tempInfo.vMusic != nil && _tempInfo.vMusic.mPath.length > 0) {
        _recorderView.musicFilePath =  _tempInfo.vMusic.mPath;
    }

}
#pragma mark - FSShortVideoRecorderViewDelegate

- (void)FSShortVideoRecorderViewQuitRecorderView {
    if (_isPresented) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        if ([[self.navigationController childViewControllers] count] == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    [[FSDraftManager sharedManager] cancleOperate];
}

- (void)FSShortVideoRecorderViewFinishRecorder:(NSString *)filePath speed:(CGFloat)speed musicStartTime:(NSTimeInterval)time {
}

- (void)FSShortVideoRecorderViewFinishRecorder:(NSString *)filePath convertFilePath:(NSString *)convertFilePath speed:(CGFloat)speed musicStartTime:(NSTimeInterval)time {
    FSPublisherController *publish = [[FSPublisherController alloc] init];
    
    _tempInfo.vType = FSDraftInfoTypeRecoder;
    _tempInfo.vSpeed = speed;
    
    if (_tempInfo.vOriginalPath != nil) {
        [FSDraftFileManager deleteFile:_tempInfo.vOriginalPath];
    }
    _tempInfo.vOriginalPath = filePath;
    _tempInfo.vFinalPath = filePath;
    _tempInfo.vConvertPath = convertFilePath;
    if (_tempInfo.vMusic) {
        _tempInfo.vMusic.mInPoint = time;
    }
    publish.draftInfo = _tempInfo;
    [[FSDraftManager sharedManager] mergeInfo];
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
-(void)dealloc{
    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

@end
