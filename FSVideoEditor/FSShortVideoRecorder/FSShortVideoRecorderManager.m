//
//  FSShortVideoRecorderManager.m
//  7nujoom
//
//  Created by 王明 on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSShortVideoRecorderManager.h"
#import "NvsVideoTrack.h"

#define MaxVideoTime 30

@interface FSShortVideoRecorderManager ()<NvsStreamingContextDelegate>

@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, strong) NvsTimeline *timeLine;
@property (nonatomic, strong) NvsVideoTrack *videoTrack;
@property (nonatomic, strong) NSString *outputFilePath;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, assign) NSInteger videoIndex;
@property (nonatomic, assign) NSInteger videoTime;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic, strong) NSMutableArray *filePathArray;
@property (nonatomic, assign) NSInteger perTime;

@end

static FSShortVideoRecorderManager *recorderManager;

@implementation FSShortVideoRecorderManager {
    NvsStreamingContext *_context;
    
    unsigned int _currentDeviceIndex;
    
    bool _supportAutoFocus;
    bool _supportAutoExposure;
    bool _fxRecord;
}


+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recorderManager = [[FSShortVideoRecorderManager alloc] init];
    });
    return recorderManager;
}

- (void)dealloc {
    NSLog(@"----FSShortVideoRecorderManager   dealloc-----");
}

- (NvsLiveWindow *)liveWindow {
    if (!_liveWindow) {
        _liveWindow = [[NvsLiveWindow alloc] init];
        //        _liveWindow.backgroundColor = [UIColor blueColor];
    }
    return _liveWindow;
}

- (NSString *)getVideoPath {
    return _videoFilePath;
}

// 恢复采集预览状态
- (void)resumeCapturePreview {
    if (!_context) {
        return;
    }
    
    // 判断当前引擎状态是否为采集预览状态，避免重复启动采集预览引起引擎停止再启动，造成启动慢或者其他不良影响
    if ([self getCurrentEngineState] == NvsStreamingEngineState_CapturePreview) {
        return;
    }
    
    // 开启采集预览
    if (![_context startCapturePreview:_currentDeviceIndex videoResGrade:NvsVideoCaptureResolutionGradeHigh flags:0 aspectRatio:nil]) {
        NSLog(@"启动预览失败");
    }
}

- (instancetype)init {
    if (self = [super init]) {
        _currentDeviceIndex = 0;
        _supportAutoFocus = false;
        _supportAutoExposure = false;
        _fxRecord = true;
        _videoIndex = 0;
        _outputFilePath = nil;
        _videoTime = 0;
        _timeArray = [NSMutableArray arrayWithCapacity:0];
        _filePathArray = [NSMutableArray arrayWithCapacity:0];
        
        // 初始化NvsStreamingContext
        _context = [NvsStreamingContext sharedInstance];
        
        if (!_context) {
            
        }
        
        // 可用采集设备的数量
        if ([_context captureDeviceCount] == 0) {
            NSLog(@"没有可用于采集的设备");
        }
        
        // 将采集预览输出连接到NvsLiveWindow控件
        if (![_context connectCapturePreviewWithLiveWindow:self.liveWindow]) {
            NSLog(@"连接预览窗口失败");
        }
        
        // 此样例使用高质量、横纵比为1:1的设置启动采集预览
        if (![_context startCapturePreview:0 videoResGrade:NvsVideoCaptureResolutionGradeHigh flags:0 aspectRatio:nil]) {
            NSLog(@"启动预览失败");
        }
        
        _context.delegate = self;
        
        
       // [self resumeCapturePreview];
    }
    return self;
}

- (NvsTimeline *)timeLine {
    if (!_timeLine) {
        NvsVideoResolution videoEditRes;
        videoEditRes.imageWidth = 1280;
        videoEditRes.imageHeight = 720;
        videoEditRes.imagePAR = (NvsRational){1,1};
        NvsRational videoFps = {25,1};
        
        NvsAudioResolution audioEditRes;
        audioEditRes.sampleRate = 48000;
        audioEditRes.channelCount =2;
        audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
        
        _timeLine = [_context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes];
    }
    return _timeLine;
}

- (NvsVideoTrack *)videoTrack {
    if (!_videoTrack) {
        _videoTrack = [self.timeLine appendVideoTrack];
    }
    return _videoTrack;
}

- (NvsLiveWindow *)getLiveWindow {
    return self.liveWindow;
}

- (void)updateSettingWithCapability:(unsigned int)deviceIndex {
    // 获取采集设备的能力描述
    NvsCaptureDeviceCapability *capability = [_context getCaptureDeviceCapability:deviceIndex];
    if (!capability) {
        return;
    }
    
    _supportAutoFocus = capability.supportAutoFocus;    // 是否支持自动聚焦
    _supportAutoExposure = capability.supportAutoExposure;  // 是否支持自动曝光

}

- (BOOL)switchCamera {
    if (_currentDeviceIndex == 0) {
        if (![_context startCapturePreview:1 videoResGrade:NvsVideoCaptureResolutionGradeHigh flags:0 aspectRatio:nil]) {
            NSLog(@"启动预览失败");
            return NO;
        }
        _currentDeviceIndex = 1;
    }
    else {
        if (![_context startCapturePreview:0 videoResGrade:NvsVideoCaptureResolutionGradeHigh flags:0 aspectRatio:nil]) {
            NSLog(@"启动预览失败");
            return NO;
        }
        _currentDeviceIndex = 0;
    }
    return YES;
}

- (void)switchFlash:(BOOL)on {
    [_context toggleFlash:on];
}

- (void)switchBeauty:(BOOL)on {
    if (on) {
        [_context removeAllCaptureVideoFx];
        [_context appendBeautyCaptureVideoFx];
    }
    else {
        [_context removeAllCaptureVideoFx];
    }
}

- (BOOL)isSupportAutoFocus {
    return _supportAutoFocus;
}

- (BOOL)isSupportAutoExposure {
    return _supportAutoExposure;
}

- (void)startAutoFocus:(CGPoint)point {
    [_context startAutoFocus:point];
}

- (void)startAutiExposure:(CGPoint)point {
    [_context startAutoExposure:point];
}

// 获取当前引擎状态
- (NvsStreamingEngineState)getCurrentEngineState {
    return [_context getStreamingEngineState];
}

- (void)startRecording:(NSString *)filePath {
    if (_videoTime >= MaxVideoTime) {
        return;
    }
    if ([self getCurrentEngineState] != NvsStreamingEngineState_CaptureRecording) {
        // 获取输出文件路径
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *outputFilePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[self getCurrentTimeString]]];
        _outputFilePath = outputFilePath;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]) {
            NSError *error;
            if ([[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:&error] == NO) {
                NSLog(@"removeItemAtPath failed, error: %@", error);
                return;
            }
        }
        
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateVideoTime)
                                                    userInfo:nil
                                                     repeats:YES];
        }
        else {
            [_timer setFireDate:[NSDate date]];
        }
        
        _perTime = 0;
        [_filePathArray addObject:outputFilePath];
        
        //开始录制
        if (_fxRecord) {
            // 使用带有特效的录制方式，此方式可以录制预览所见的所有效果，包括特效和宽高比
            if (![_context startRecordingWithFx:outputFilePath]) {
                [self resumeCapturePreview];
                [_context startRecordingWithFx:outputFilePath];
            }
        }
        else {
            // 使用不带有特效的录制方式，此方式只能录制相机采集到的原始图像，不带有任何特效，宽高比也由相机设备自身决定
            if (![_context startRecordingWithFx:outputFilePath]) {
                [self resumeCapturePreview];
                [_context startRecording:outputFilePath];
            }
        }
    }
}

- (void)updateVideoTime {
    _videoTime++;
    _perTime++;
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerProgress:)]) {
        [self.delegate FSShortVideoRecorderManagerProgress:_videoTime];
    }
    NSLog(@"%ld",_videoTime);
}

- (void)quitRecording {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    
    if ([self getCurrentEngineState] == NvsStreamingEngineState_CaptureRecording) {
        [_context stopRecording];
    }
    
    _context.delegate = nil;
    _context = nil;
}

- (void)stopRecording {
    if ([_timer isValid]) {
        [_timer setFireDate:[NSDate distantFuture]];
    }
    [_context stopRecording];
    
    _videoIndex++;
    
//    NSData * fileData = [NSData dataWithContentsOfFile:_outputFilePath];
//    NSLog(@"data:  %ld",fileData.length);
//    
//    
//    // 保存视频
//    UISaveVideoAtPathToSavedPhotosAlbum(_outputFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    
    [_timeArray addObject:[NSNumber numberWithInteger:_perTime]];
}

// 视频保存回调

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    
    NSLog(@"%@",videoPath);
    
    NSLog(@"%@",error);
    
}

- (NSString *)getCurrentTimeString {
    NSDate * today = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:today];
    NSDate *localeDate = [today dateByAddingTimeInterval:interval];
    NSLog(@"%@", localeDate);
    // 时间转换成时间戳
    NSString *timeSp = [NSString stringWithFormat:@"%ld",(long)[localeDate timeIntervalSince1970]];
    NSLog(@"timeSp : %@", timeSp);
    return timeSp;
}

- (BOOL)finishRecorder {
    if ([self getCurrentEngineState] == NvsStreamingEngineState_CaptureRecording) {
        [self stopRecording];
    }
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    for (NSString *path in _filePathArray) {
        [self.videoTrack appendClip:path];
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
    
    
    _videoFilePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[self getCurrentTimeString]]];
    
    BOOL isSuccess = [_context compileTimeline:self.timeLine startTime:0 endTime:self.timeLine.duration outputFilePath:_videoFilePath videoResolutionGrade:NvsCompileVideoResolutionGrade720 videoBitrateGrade:NvsCompileBitrateGradeHigh flags:0];
    if (isSuccess) {
        _videoIndex = 0;
        _outputFilePath = nil;
       // UISaveVideoAtPathToSavedPhotosAlbum(_videoFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);

    }
    return isSuccess;
    
}

- (BOOL)deleteVideoFile {
//    BOOL success = [self.videoTrack removeClip:(unsigned int)_videoIndex keepSpace:false];
//    if (success) {
    if (_videoIndex == 0) {
        return NO;
    }
        NSInteger time = [[_timeArray objectAtIndex:_videoIndex-1] integerValue];
        _videoTime = _videoTime - time;
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerDeleteVideo:)]) {
        [self.delegate FSShortVideoRecorderManagerDeleteVideo:_videoTime];
    }
        [_timeArray removeLastObject];
    
    [_filePathArray removeLastObject];

        _videoIndex--;
   // }
    return YES;
}

#pragma mark - NvsStreamingContextDelegate
- (void)didCaptureDeviceCapsReady:(unsigned int)captureDeviceIndex {
    if (captureDeviceIndex != _currentDeviceIndex) {
        return;
    }
    
    [self updateSettingWithCapability:captureDeviceIndex];
}

- (void)didCompileProgress:(NvsTimeline *)timeline progress:(int)progress {
    NSLog(@"didCompileProgress  %d",progress);
    
}

- (void)didCompileFinished:(NvsTimeline *)timeline {
    NSLog(@"didCompileFinished");
    UISaveVideoAtPathToSavedPhotosAlbum(_videoFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerFinishRecorder:)]) {
        [self.delegate FSShortVideoRecorderManagerFinishRecorder:_videoFilePath];
    }


}

- (void)didCompileFailed:(NvsTimeline *)timeline {
    NSLog(@"didCompileFailed");

}

@end
