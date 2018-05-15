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
#import "FSAlertView.h"
#import "FSFilterView.h"
#import "FSDraftManager.h"
#import "FSMusicPlayer.h"
#import "FSMusicController.h"
#import "FSLocalVideoToolController.h"
#import "FSMusicToolController.h"
#import "FSVideoEditorCommenData.h"

@interface FSShortVideoRecorderController ()<FSShortVideoRecorderViewDelegate, FSFilterViewDelegate, FSMusicControllerDelegate,FSMusicToolControllerDelegate>
{
    FSDraftInfo *_tempInfo;
}

@property (nonatomic, strong) FSShortVideoRecorderView *recorderView;
@property (nonatomic, strong) FSFilterView *filterView;
@property (nonatomic, assign) BOOL isCurrentView;
@property (nonatomic, strong) UIViewController *childController;

@end

@implementation FSShortVideoRecorderController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
     _tempInfo = [[FSDraftManager sharedManager] draftInfoWithPreInfo:_draftInfo];
    [_tempInfo clearFxInfos];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:@"kNSNotificationInhoneDidBecomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requireMusicDetailVC:) name:@"kNSNotificationRequireMusicDetailVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitRecorderView) name:@"kNSNoticeficationUploadShortVideoSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitRecorderViewDelay) name:@"kNotificationDeepLinkOrPush" object:nil];

    
}

- (void)quitRecorderViewDelay {
    [self performSelector:@selector(quitRecorderView) withObject:nil afterDelay:0.3];
}

- (void) quitRecorderView {
    NSLog(@"kNotificationDeepLinkOrPush %@",self);
    if (_isPresented) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else {
        if ([[self.navigationController childViewControllers] count] == 1) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }else{
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    
    [[FSDraftManager sharedManager] cancleOperate];}

- (void)becomeActive {
    if (_recorderView &&  _isCurrentView) {
        [_recorderView resumeCapturePreview];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isCurrentView = YES;
    _childController = nil;

    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    if (!_recorderView) {
        _recorderView = [[FSShortVideoRecorderView alloc] initWithFrame:self.view.bounds draftInfo:_tempInfo];
        _recorderView.delegate =self;
        [self.view addSubview:_recorderView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isCurrentView = NO;

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    [[FSMusicPlayer sharedPlayer] setRate:1.0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    
    [_recorderView resumeCapturePreview];
    if (_tempInfo.vMusic != nil && _tempInfo.vMusic.mPath.length > 0) {
        _recorderView.musicFilePath =  _tempInfo.vMusic.mPath;
    }

}

- (void)showNoviceGuideView:(UIView *)guideView {
    
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
    
//    if (_tempInfo.vOriginalPath != nil) {
//        [FSDraftFileManager deleteFile:_tempInfo.vOriginalPath];
//    }
    _tempInfo.vOriginalPath = filePath;
    _tempInfo.vFinalPath = filePath;
    _tempInfo.vConvertPath = convertFilePath;
    if (_tempInfo.vMusic) {
        _tempInfo.vMusic.mInPoint = time * 1000000.0;
    }
    publish.draftInfo = _tempInfo;
    //[[FSDraftManager sharedManager] mergeInfo];
    [self.navigationController pushViewController:publish animated:YES];
}


- (void)FSShortVideoRecorderViewShowAlertView:(NSString *)message {
    FSAlertView *alet = [[FSAlertView alloc] initWithFrame:self.view.bounds];
    [alet showWithMessage:message];
}

- (void)FSShortVideoRecorderViewShowFilterView {
    if (!_filterView) {
        _filterView = [[FSFilterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-120, self.view.frame.size.width, 120) filterName:_tempInfo.vFilterid];
        _filterView.backgroundColor = [UIColor clearColor];
        _filterView.hidden = YES;
        _filterView.delegate =self;
        [self.view addSubview:_filterView];
    }
    
    _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.view.frame.size.height, _filterView.frame.size.width, _filterView.frame.size.height);
    _filterView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.view.frame.size.height-_filterView.frame.size.height-FSSafeAreaBottomHeight, _filterView.frame.size.width, _filterView.frame.size.height);
        
    }];
}
- (void)FSFilterViewChooseFilter:(NSString *)filter {
    _tempInfo.vFilterid = filter;
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

- (void)FSShortVideoRecorderViewChooseMusic {
//    FSMusicController *music = [FSMusicController new];
//
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:music];
//    [nav setNavigationBarHidden:YES];
//
//   // music.timeLine = _timeLine;
//    music.pushed = YES;
//    music.needSelfHeader = YES;
//    music.shouldReturnMusic = YES;
//    [music setDelegate:self];
//
//    [self presentViewController:nav animated:YES completion:nil];
    
    FSMusicToolController *toolController = [[FSMusicToolController alloc] init];
    //FSLocalVideoToolController *toolController = [[FSLocalVideoToolController alloc] init];
    [toolController setDelegate:self];
    toolController.musicView.pushed = YES;
    toolController.musicView.needSelfHeader = YES;
    toolController.musicView.shouldReturnMusic = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:toolController];
    [self presentViewController:nav animated:YES completion:nil];
    
    _childController = toolController;

}

- (void)FSShortVideoRecorderViewEnterLocalVideoView {
    FSLocalVideoToolController *toolController = [[FSLocalVideoToolController alloc] init];
    //[toolController setDelegate:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:toolController];
    [self presentViewController:nav animated:YES completion:nil];
    
    _childController = toolController;

}

- (void)FSMusicToolVCDidSelectedMusic:(FSMusic *)music filePath:(NSString *)filePath {
    if (music != nil && filePath.length > 0) {
        _recorderView.musicFilePath = filePath;
    }
}

#pragma mark - FSMusicControllerDelegate
-(void)musicControllerSelectMusic:(NSString *)musicPath music:(FSMusic *)music{
    if (music != nil && musicPath.length > 0) {
        _recorderView.musicFilePath = musicPath;
//        [_toolView canEditMusic:YES];
//        [_toolView updateMusicInfo:music];
        
//        NvsAudioTrack *musicTrack = [_timeLine getAudioTrackByIndex:1];
//        if (!musicTrack) {
//            musicTrack =  [_timeLine appendAudioTrack];
//
//        }
//        [musicTrack removeAllClips];
//        [musicTrack appendClip:musicPath];
//
//        // 原音音轨
//        NvsAudioTrack *audioTrack = [_timeLine getAudioTrackByIndex:0];
//        _tempDraftInfo.vOriginalVolume = -1;
//        [audioTrack setVolumeGain:0.0 rightVolumeGain:0.0];
//
//        if (_tempDraftInfo.vMusicVolume == -1) {
//            _tempDraftInfo.vMusicVolume = 0.5;
//        }
//
//        [musicTrack setVolumeGain:_tempDraftInfo.vMusicVolume rightVolumeGain:_tempDraftInfo.vMusicVolume];
        
    }
}

-(UIViewController *)FSMusicToolVCDidShowMusicDetailWithMusic:(FSMusic *)music{
    
    UIViewController *deatilController = nil;
    
    if ([self.delegate respondsToSelector:@selector(FSShortVideoShowMusicDetailWithMusic:)]) {
        deatilController = [self.delegate FSShortVideoShowMusicDetailWithMusic:music];
    }
    
    NSAssert(![deatilController isKindOfClass:[UINavigationController class]], @"返回的控制器不能为nav");
    return deatilController;
}

- (void)requireMusicDetailVC:(NSNotification *)noti {
    NSDictionary *dict = noti.object;

    FSMusic *music = [FSMusic new];
    music.songId = [[dict objectForKey:@"songId"] integerValue];
    music.songAuthor = [dict objectForKey:@"songAuthor"];
    music.songPic = [dict objectForKey:@"songPic"];
    music.songTitle = [dict objectForKey:@"songTitle"];
    music.songUrl = [dict objectForKey:@"songUrl"];
    
    UIViewController *deatilController = [self FSMusicToolVCDidShowMusicDetailWithMusic:music];
    if (deatilController) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNSNoticeficationGetMusicDetailVCSucceed" object:[NSDictionary dictionaryWithObject:deatilController forKey:@"musicDeatilController"]];

    }
    
}

- (void)musicControllerHideen {
}

-(void)dealloc{
//    if (_childController) {
//        [_childController.navigationController dismissViewControllerAnimated:NO completion:^{
//
//        }];
//    }
//
//    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderDismiss)]) {
//        [self.delegate FSShortVideoRecorderDismiss];
//    }
    
    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kNSNotificationInhoneDidBecomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kNSNotificationRequireMusicDetailVC" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kNSNoticeficationUploadShortVideoSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kNotificationDeepLinkOrPush" object:nil];

}

@end
