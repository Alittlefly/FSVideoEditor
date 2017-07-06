//
//  FSShortVideoRecorderManager.m
//  7nujoom
//
//  Created by 王明 on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSShortVideoRecorderManager.h"
#import "NvsVideoTrack.h"
#import "NvcConvertor.h"
#import "NvsVideoClip.h"

#define MaxVideoTime 15

@interface FSShortVideoRecorderManager ()<NvsStreamingContextDelegate, NvcConvertorDelegate>

@property (nonatomic, strong) NvsLiveWindow *liveWindow;
@property (nonatomic, strong) NvsTimeline *timeLine;
@property (nonatomic, strong) NvsVideoTrack *videoTrack;
@property (nonatomic, strong) NSString *outputFilePath;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, assign) NSInteger videoIndex;
@property (nonatomic, assign) CGFloat videoTime;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic, strong) NSMutableArray *filePathArray;
@property (nonatomic, strong) NSMutableArray *speedArray;
@property (nonatomic, assign) CGFloat perTime;

@property (nonatomic, strong) NvcConvertor *mConvertor;
@property (nonatomic, copy) NSString *convertorFilePath;

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

- (NvcConvertor *)mConvertor {
    if (!_mConvertor) {
        _mConvertor = [[NvcConvertor alloc] init];
        _mConvertor.delegate = self;
    }
    return _mConvertor;
}

- (NSString *)getVideoPath {
    return _videoFilePath;
}

// 恢复采集预览状态
- (void)resumeCapturePreview {
    if (!_context) {
        return;
    }
    
    if (!_context.delegate) {
        _context.delegate = self;
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

- (void)setRecorderSpeed:(CGFloat)recorderSpeed {
    _recorderSpeed = recorderSpeed;
    
}

- (instancetype)init {
    if (self = [super init]) {
        [self initBaseData];
        
        
       // [self resumeCapturePreview];
    }
    return self;
}

- (void)initBaseData {
    _currentDeviceIndex = 0;
    _supportAutoFocus = false;
    _supportAutoExposure = false;
    _fxRecord = true;
    _videoIndex = 0;
    _outputFilePath = nil;
    _videoTime = 0;
    _recorderSpeed = 1;
    _timeArray = [NSMutableArray arrayWithCapacity:0];
    _filePathArray = [NSMutableArray arrayWithCapacity:0];
    _speedArray = [NSMutableArray arrayWithCapacity:0];
    
    [self initContext];
}

- (void)initContext {
    if (_context) {
        _context.delegate = self;
        [self resumeCapturePreview];
        return;
        
    }
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
}

- (void)clearData {
    _supportAutoFocus = false;
    _supportAutoExposure = false;
    _fxRecord = true;
    _videoIndex = 0;
    _outputFilePath = nil;
    _videoTime = 0;
    _timeArray = nil;
    _filePathArray = nil;
    _speedArray = nil;
    
//    for (int i = 0; i < [self.timeLine videoTrackCount]; i++) {
//        NvsVideoTrack *track = [self.timeLine getVideoTrackByIndex:i];
//    }
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Stopped)
        [_context stop];
    _context.delegate = nil;
    _context = nil;
}

- (NvsTimeline *)timeLine {
    if (!_timeLine) {
        _timeLine = [self createTimeLine];
    }
    return _timeLine;
}

- (NvsTimeline *)createTimeLine {
    NvsVideoResolution videoEditRes;
    videoEditRes.imageWidth = 1280;
    videoEditRes.imageHeight = 720;
    videoEditRes.imagePAR = (NvsRational){1,1};
    NvsRational videoFps = {25,1};
    
    NvsAudioResolution audioEditRes;
    audioEditRes.sampleRate = 48000;
    audioEditRes.channelCount =2;
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
    
   return [_context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes];
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

- (void)addFilter:(NSString *)filter {
    if ([filter isEqualToString:@"None"]) {
        [_context removeAllCaptureVideoFx];
    }
    else {
        [_context removeAllCaptureVideoFx];
        [_context appendBuiltinCaptureVideoFx:filter];
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

- (NSArray *)getAllVideoFilters {
    return [_context getAllBuiltinVideoFxNames];
}

- (void)startRecording:(NSString *)filePath {
    if (_videoTime >= MaxVideoTime) {
        if ([_timer isValid]) {
            [_timer setFireDate:[NSDate distantFuture]];
        }
        return;
    }
    if ([self getCurrentEngineState] != NvsStreamingEngineState_CaptureRecording) {
        // 获取输出文件路径
        NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *outputFilePath = [[docPath objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[self getCurrentTimeString]]];
        
       // NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
       // NSString *outputFilePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[self getCurrentTimeString]]];
        _outputFilePath = outputFilePath;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]) {
            NSError *error;
            if ([[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:&error] == NO) {
                NSLog(@"removeItemAtPath failed, error: %@", error);
                return;
            }
        }
        
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
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
    _videoTime= _videoTime+0.1*_recorderSpeed;
    _perTime = _perTime+0.1*_recorderSpeed;
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerProgress:)]) {
        [self.delegate FSShortVideoRecorderManagerProgress:_videoTime];
    }
    NSLog(@"_videoTime: %f    _perTime: %f",_videoTime,_perTime);
}

- (void)quitRecording {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    
    if ([self getCurrentEngineState] == NvsStreamingEngineState_CaptureRecording) {
        [_context stopRecording];
    }
    
    for (NSString *path in _filePathArray) {
        [self deleteCacheFile:path];
    }
    [_filePathArray removeAllObjects];
    
    if([_context getStreamingEngineState] != NvsStreamingEngineState_Stopped)
        [_context stop];
    _context.delegate = nil;
    _context = nil;
}

- (void)stopRecording {
    if ([self getCurrentEngineState] != NvsStreamingEngineState_CaptureRecording) {
        return;
    }
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
 //   UISaveVideoAtPathToSavedPhotosAlbum(_outputFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//    [self.videoTrack appendClip:_outputFilePath];

    
    [_timeArray addObject:[NSNumber numberWithFloat:_perTime]];
    
    CGFloat speed = 1;
    if (_recorderSpeed == 3) {
        speed = 1.0/3.0;
    }
    else if (_recorderSpeed == 2) {
        speed = 0.5;
    }
    else if (_recorderSpeed == 1) {
        speed = 1;
    }
    else if (_recorderSpeed == 0.5) {
        speed = 2;
    }
    else if (_recorderSpeed == 1.0/3.0) {
        speed = 3;
    }
    
    [_speedArray addObject:[NSNumber numberWithFloat:speed]];
    
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerPauseRecorder)]) {
        [self.delegate FSShortVideoRecorderManagerPauseRecorder];
    }
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
    
    //NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    
    
    [self.videoTrack removeAllClips];
    int i = 0;
    for (NSString *path in _filePathArray) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path])
        {
            CGFloat speed = [[_speedArray objectAtIndex:i] floatValue];
            NvsVideoClip *clip = [self.videoTrack appendClip:path];
            [clip changeSpeed:speed];
            NSLog(@"----speed:%f  duration:%lld   count:%d ",speed,self.timeLine.duration,[self.timeLine videoTrackCount]);
        }
        i++;
       // UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
    
    
    _videoFilePath = [[docPath objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[self getCurrentTimeString]]];//[docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[self getCurrentTimeString]]];
    
//    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerFinish:)]) {
//        [self.delegate FSShortVideoRecorderManagerFinish:self.timeLine];
//    }
//    
//    return YES;
    
    BOOL isSuccess = [_context compileTimeline:self.timeLine startTime:0 endTime:self.timeLine.duration outputFilePath:_videoFilePath videoResolutionGrade:NvsCompileVideoResolutionGrade720 videoBitrateGrade:NvsCompileBitrateGradeHigh flags:0];
    if (isSuccess) {
//        _videoIndex = 0;
//        _outputFilePath = nil;
//        UISaveVideoAtPathToSavedPhotosAlbum(_videoFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);

    }
    return isSuccess;
    
}

- (BOOL)deleteVideoFile {
//    BOOL success = [self.videoTrack removeClip:(unsigned int)_videoIndex keepSpace:false];
//    if (success) {
    if (_timeArray.count == 0) {
        return NO;
    }
    CGFloat time = [[_timeArray objectAtIndex:_videoIndex-1] floatValue];
    _videoTime = _videoTime - time;
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerDeleteVideo:)]) {
        [self.delegate FSShortVideoRecorderManagerDeleteVideo:_videoTime];
    }
    [_timeArray removeLastObject];
    [_speedArray removeLastObject];
    
        //文件名
    NSString *uniquePath= [_filePathArray lastObject];
    BOOL deleted= [self deleteCacheFile:uniquePath];
    if (deleted) {
        [_filePathArray removeLastObject];
    }


        _videoIndex--;
   // }
    return YES;
}

- (BOOL)deleteCacheFile:(NSString *)filePath {
    BOOL deleted = NO;
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!blHave) {
        NSLog(@"no  have");
    }else {
        NSLog(@" have");
        BOOL blDele= [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        if (blDele) {
            NSLog(@"dele success");
            deleted = YES;
        }else {
            NSLog(@"dele fail");
        }
        
    }
    return deleted;
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
    //UISaveVideoAtPathToSavedPhotosAlbum(_videoFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    [self setupConvertor:_videoFilePath];
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerFinishRecorder:)]) {
        [self.delegate FSShortVideoRecorderManagerFinishRecorder:_videoFilePath];
    }

  //  [self clearData];

}

- (void)didCompileFailed:(NvsTimeline *)timeline {
    NSLog(@"didCompileFailed");
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerFailedRecorder)]) {
        [self.delegate FSShortVideoRecorderManagerFailedRecorder];
    }
}

#pragma mark - NVConvertorDelegate
- (void)convertFinished {
    [self.mConvertor stop];
    [self.mConvertor close];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_convertorFilePath] == NO)
    {
        [self convertFaild:nil];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerConvertorFinished:)]) {
            [self.delegate FSShortVideoRecorderManagerConvertorFinished:_convertorFilePath];
        }
        
        if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerFinishedRecorder:convertFilePath:)]) {
            [self.delegate FSShortVideoRecorderManagerFinishedRecorder:_videoFilePath convertFilePath:_convertorFilePath];
        }
    }
}

- (void)convertFaild:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerConvertorFaild)]) {
        [self.delegate FSShortVideoRecorderManagerConvertorFaild];
    }
}

- (BOOL)beginConvertReverse:(NSString *)filePath {
    if (filePath == nil) {
        return NO;
    }
    
    if ([self.mConvertor IsOpened]) {
        [self.mConvertor stop];
        [self.mConvertor close];
        return NO;
    }
    
    [self setupConvertor:filePath];
    return YES;
}

- (void)setupConvertor:(NSString *)filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *tmpfilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[self getCurrentTimeString]]];
    _convertorFilePath = tmpfilePath;
    
    struct SNvcOutputConfig config ;
    config.from = 0;
    config.to = INT_MAX;
    config.dataRate = 0;
    config.scale.num = 1;
    config.scale.den = 1;
    
    //倒序
    int nTmp = config.from;
    config.from = config.to;
    config.to = nTmp;
    
    NSInteger ret = [self.mConvertor open:filePath outputFile:tmpfilePath setting:&config];
    if (ret != NVC_NOERROR) {
        NSString *error = nil;
        if (ret == NVC_E_INVALID_POINTER) {
            error = @"无效指针";
        }
        else if (ret == NVC_E_INVALID_PARAMETER) {
            error = @"无效参数";
        }
        else if (ret == NVC_E_NO_VIDEO_STREAM) {
            error = @"输入文件不存在视频流";
        }
        else if (ret == NVC_E_CONVERTOR_IS_OPENED) {
            error = @"当前转码器已经打开";
        }
        else if (ret == NVC_E_CONVERTOR_IS_STARTED) {
            error = @" 正在转码";
        }
        return;
    }
    
    [self.mConvertor start];
}

@end
