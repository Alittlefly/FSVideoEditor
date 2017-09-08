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
#import "NvsTimelineAnimatedSticker.h"
#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"

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

@property (nonatomic, assign) CGFloat perTime;

@property (nonatomic, strong) NvcConvertor *mConvertor;
@property (nonatomic, copy) NSString *convertorFilePath;

@property (nonatomic, strong) FSDraftInfo *draftInfo;

@property (nonatomic, strong) NSMutableDictionary *filtersDic;

@end

static FSShortVideoRecorderManager *recorderManager;

@implementation FSShortVideoRecorderManager {
    NvsStreamingContext *_context;
    
    unsigned int _currentDeviceIndex;
    
    bool _supportAutoFocus;
    bool _supportAutoExposure;
    bool _fxRecord;
    
    NSMutableString* _stickerPackageId;

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
        [self initBaseData:[[FSDraftInfo alloc] init]];
        
        
       // [self resumeCapturePreview];
    }
    return self;
}

- (void)initBaseData:(FSDraftInfo *)draftInfo {
    _currentDeviceIndex = draftInfo.isFrontCamera ? 1 : 0;
    _supportAutoFocus = false;
    _supportAutoExposure = false;
    _fxRecord = true;
    _draftInfo = draftInfo;
    _filtersDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    _filePathArray = [NSMutableArray arrayWithArray:draftInfo.recordVideoPathArray];
    _timeArray = [NSMutableArray arrayWithArray:draftInfo.recordVideoTimeArray];
    _speedArray = [NSMutableArray arrayWithArray:draftInfo.recordVideoSpeedArray];
    
    _videoIndex = _filePathArray.count;
    _outputFilePath = nil;
    _videoTime = 0.0;
    _perTime = 0.0;
    for (NSNumber *time in _timeArray) {
        _videoTime += time.doubleValue;
    }
    _recorderSpeed = 1.0;
    
    [self initContext];
}

- (void)initContext {
    if (_context) {
        _context.delegate = self;
        [self resumeCapturePreview];
        return;
        
    }
    NSString *verifySdkLicenseFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"198-14-f6192de5110aed067060b4010c648cac.lic"];

    BOOL isOK = [NvsStreamingContext verifySdkLicenseFile:verifySdkLicenseFilePath];
    
    NSLog(@"verify:%@  %D",verifySdkLicenseFilePath,isOK);
    // 初始化NvsStreamingContext
    _context = [NvsStreamingContext sharedInstanceWithFlags:(NvsStreamingContextFlag_Support4KEdit)];
    
    
    // 可用采集设备的数量
    if ([_context captureDeviceCount] == 0) {
        NSLog(@"没有可用于采集的设备");
    }
    
    // 将采集预览输出连接到NvsLiveWindow控件
    if (![_context connectCapturePreviewWithLiveWindow:self.liveWindow]) {
        NSLog(@"连接预览窗口失败");
    }
    
    // 此样例使用高质量、横纵比为1:1的设置启动采集预览
    if (![_context startCapturePreview:_currentDeviceIndex videoResGrade:NvsVideoCaptureResolutionGradeHigh flags:0 aspectRatio:nil]) {
        NSLog(@"启动预览失败");
    }
    
    _context.delegate = self;
    
    [self getSticker];
}

- (void)initStickerData {
    NSString *appPath =[[NSBundle mainBundle] bundlePath];
    NSString *stickerFilePath = [appPath stringByAppendingPathComponent:@"07D3BBED-1276-42A6-577A-04A36100FA1A.animatedsticker"];
    NSString *stickerLicFilePath = [appPath stringByAppendingPathComponent:@"07D3BBED-1276-42A6-577A-04A36100FA1A.lic"];
    _stickerPackageId = [[NSMutableString alloc] initWithString:@""];

    if (![[NSFileManager defaultManager] fileExistsAtPath:stickerFilePath]) {
        NSLog(@"Sticker package file is not exist!");
    } else {
        // 此处选择同步安装，如果包裹过大或者根据需要，可选择异步安装
        NvsAssetPackageManagerError error = [_context.assetPackageManager installAssetPackage:stickerFilePath license:stickerLicFilePath type:NvsAssetPackageType_AnimatedSticker sync:YES assetPackageId:_stickerPackageId];
        if (error != NvsAssetPackageManagerError_NoError && error != NvsAssetPackageManagerError_AlreadyInstalled) {
            NSLog(@"Failed to install sticker package!");
        }
    }
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
    videoEditRes.imageWidth = 540;
    videoEditRes.imageHeight = 960;
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
    [_context removeAllCaptureVideoFx];

    if ([filter isEqualToString:@"NoFilter"]) {
    }
    else {
        if ([[self.filtersDic allKeys] containsObject:filter]) {
            [_context appendPackagedCaptureVideoFx:[self.filtersDic objectForKey:filter]];
        }
        else {
            [_context appendBuiltinCaptureVideoFx:filter];
        }
    }
}

- (void)addFilter:(NSString *)filterId toVideoClip:(NvsVideoClip *)clip {
    [clip removeAllFx];
    
    if ([filterId isEqualToString:@"NoFilter"]) {
    }
    else {
        if ([[self.filtersDic allKeys] containsObject:filterId]) {
            [clip appendPackagedFx:[self.filtersDic objectForKey:filterId]];
        }
        else {
            [clip appendBuiltinFx:filterId];
        }
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

- (void)addFilter:(NSString *)filterName filterPath:(NSString *)filterPath license:(NSString *)license {
    NSMutableString *filterId = [[NSMutableString alloc] initWithString:@""];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filterPath]) {
        NSLog(@"包裹1不存在");
    } else {
        // 此处采用同步安装方式，如果包裹过大可采用异步方式
        NvsAssetPackageManagerError error = [_context.assetPackageManager installAssetPackage:filterPath license:license type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:filterId];
        if (error != NvsAssetPackageManagerError_NoError && error != NvsAssetPackageManagerError_AlreadyInstalled) {
            NSLog(@"包裹1安装失败");
        }
        else {
            [self.filtersDic setObject:filterId forKey:filterName];
        }
    }
}

- (void)initFilters {
   NSString *fxPackageId1 = [NSString stringWithFormat:@"BW"];
    NSString *appPath =[[NSBundle mainBundle] bundlePath];
    NSString *package1Path = [appPath stringByAppendingPathComponent:@"33F513E5-5CA2-4C23-A6D4-8466202EE698.2.videofx"];
    NSString *license1Path = [appPath stringByAppendingPathComponent:@"33F513E5-5CA2-4C23-A6D4-8466202EE698.lic"];
    [self addFilter:fxPackageId1 filterPath:package1Path license:license1Path];
    
    NSString *fxPackageId2 = [NSString stringWithFormat:@"Classic"];
    NSString *package2Path = [appPath stringByAppendingPathComponent:@"707EB4BC-2FD0-46FA-B607-ABA3F6CE7250.1.videofx"];
    NSString *license2Path = [appPath stringByAppendingPathComponent:@"707EB4BC-2FD0-46FA-B607-ABA3F6CE7250.lic"];
    [self addFilter:fxPackageId2 filterPath:package2Path license:license2Path];

    NSString *fxPackageId3 = [NSString stringWithFormat:@"Classical"];
    NSString *package3Path = [appPath stringByAppendingPathComponent:@"34897DAA-8F41-4862-84CD-5573F8D6787B.1.videofx"];
    NSString *license3Path = [appPath stringByAppendingPathComponent:@"34897DAA-8F41-4862-84CD-5573F8D6787B.lic"];
    [self addFilter:fxPackageId3 filterPath:package3Path license:license3Path];

    NSString *fxPackageId4 = [NSString stringWithFormat:@"IceBlue"];
    NSString *package4Path = [appPath stringByAppendingPathComponent:@"B3E53F0E-BE67-4A2D-AEC8-CF5F8E064EF1.1.videofx"];
    NSString *license4Path = [appPath stringByAppendingPathComponent:@"B3E53F0E-BE67-4A2D-AEC8-CF5F8E064EF1.lic"];
    [self addFilter:fxPackageId4 filterPath:package4Path license:license4Path];
    
    NSString *fxPackageId5 = [NSString stringWithFormat:@"LOMO"];
    NSString *package5Path = [appPath stringByAppendingPathComponent:@"51986EDA-1D6F-4C6C-961C-1891ECB83E30.1.videofx"];
    NSString *license5Path = [appPath stringByAppendingPathComponent:@"51986EDA-1D6F-4C6C-961C-1891ECB83E30.lic"];
    [self addFilter:fxPackageId5 filterPath:package5Path license:license5Path];
    
    NSString *fxPackageId6 = [NSString stringWithFormat:@"RisingSun"];
    NSString *package6Path = [appPath stringByAppendingPathComponent:@"9547C6E5-18DA-4C31-97B6-40B934BA0CD6.1.videofx"];
    NSString *license6Path = [appPath stringByAppendingPathComponent:@"9547C6E5-18DA-4C31-97B6-40B934BA0CD6.lic"];
    [self addFilter:fxPackageId6 filterPath:package6Path license:license6Path];

    NSString *fxPackageId7 = [NSString stringWithFormat:@"Sweetie"];
    NSString *package7Path = [appPath stringByAppendingPathComponent:@"D61B2771-819A-44EB-8C6B-D86803714429.1.videofx"];
    NSString *license7Path = [appPath stringByAppendingPathComponent:@"D61B2771-819A-44EB-8C6B-D86803714429.lic"];
    [self addFilter:fxPackageId7 filterPath:package7Path license:license7Path];

    NSString *fxPackageId8 = [NSString stringWithFormat:@"TheGoldenTimes"];
    NSString *package8Path = [appPath stringByAppendingPathComponent:@"6A226E39-A423-4F4F-92EF-9275D0CDD2EF.2.videofx"];
    NSString *license8Path = [appPath stringByAppendingPathComponent:@"6A226E39-A423-4F4F-92EF-9275D0CDD2EF.lic"];
    [self addFilter:fxPackageId8 filterPath:package8Path license:license8Path];

    NSString *fxPackageId9 = [NSString stringWithFormat:@"WarmTea"];
    NSString *package9Path = [appPath stringByAppendingPathComponent:@"83350933-EBA9-4947-A226-BE1DDA953902.1.videofx"];
    NSString *license9Path = [appPath stringByAppendingPathComponent:@"83350933-EBA9-4947-A226-BE1DDA953902.lic"];
    [self addFilter:fxPackageId9 filterPath:package9Path license:license9Path];

    NSString *fxPackageId10 = [NSString stringWithFormat:@"Yummy"];
    NSString *package10Path = [appPath stringByAppendingPathComponent:@"02B33530-8663-4A01-A6F1-C9DAB3322590.2.videofx"];
    NSString *license10Path = [appPath stringByAppendingPathComponent:@"02B33530-8663-4A01-A6F1-C9DAB3322590.lic"];
    [self addFilter:fxPackageId10 filterPath:package10Path license:license10Path];
}

- (NSArray *)getAllVideoFilters {
    if (self.filtersDic.count == 0) {
        [self initFilters];
    }
    if (self.filtersDic.count > 0) {
        return [self.filtersDic allKeys];
    }
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
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *final = [documentsDirectory stringByAppendingPathComponent:@"tmp"];
        NSString *outputFilePath = [final stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[self getCurrentTimeString]]];
        
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
            [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
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
    double perAddTime = 0.1;
    _videoTime= _videoTime+perAddTime*_recorderSpeed;
    _perTime = _perTime+perAddTime*_recorderSpeed;
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerProgress:)]) {
        NSString *newTime = [NSString stringWithFormat:@"%.6f",_videoTime];

        [self.delegate FSShortVideoRecorderManagerProgress:newTime.floatValue];
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *final = [documentsDirectory stringByAppendingPathComponent:@"tmp"];
    
    [self.videoTrack removeAllClips];
    int i = 0;
    for (NSString *path in _filePathArray) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path])
        {
            CGFloat speed = [[_speedArray objectAtIndex:i] floatValue];
            NvsVideoClip *clip = [self.videoTrack appendClip:path];
            [clip changeSpeed:speed];
//            NSLog(@"----speed:%f  duration:%lld   count:%d ",speed,self.timeLine.duration,[self.timeLine videoTrackCount]);
        }
        i++;
       // UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
    
    if (_filePathArray.count > 1) {
        for (int i = 0; i < _filePathArray.count-1; i++) {
            [self.videoTrack setBuiltinTransition:i withName:nil];
        }
    }
    
    _videoFilePath = [final stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[self getCurrentTimeString]]];//[docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[self getCurrentTimeString]]];
    
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
    
    //文件名
    NSString *uniquePath= [_filePathArray lastObject];
    if ([_draftInfo.recordVideoPathArray containsObject:uniquePath]) {
        BOOL deleted= [self deleteCacheFile:uniquePath];
        if (deleted) {
            [_filePathArray removeLastObject];
        }
        else {
            return NO;
        }
    }
    else {
        [_filePathArray removeLastObject];
    }
    
    CGFloat time = [[_timeArray objectAtIndex:_videoIndex-1] floatValue];
    _videoTime = _videoTime - time;
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerDeleteVideo:)]) {
        NSString *newTime = [NSString stringWithFormat:@"%.6f",_videoTime];
        
        [self.delegate FSShortVideoRecorderManagerDeleteVideo:newTime.floatValue];
    }
    [_timeArray removeLastObject];
    [_speedArray removeLastObject];


        _videoIndex--;
   // }
    return YES;
}

#pragma mark - Sticker
- (void)addSticker:(NSMutableString *)sticker timeLine:(NvsTimeline *)timeline {
    if ([sticker isEqualToString:@""])
        sticker = _stickerPackageId;
    // 添加动画贴纸
    NvsTimelineAnimatedSticker *stickers = [timeline addAnimatedSticker:0 duration:timeline.duration animatedStickerPackageId:_stickerPackageId];
    //[stickers setScale:0.4];
    NvsRect stickerRect = [stickers getOriginalBoundingRect];
    
    CGPoint topLeftCorner = CGPointMake(stickerRect.left, stickerRect.top);
    CGPoint rightBottomCorner = CGPointMake(stickerRect.right, stickerRect.bottom);
    
    CGPoint liveWindowRightBottom = [_liveWindow mapViewToCanonical:CGPointMake(_liveWindow.frame.size.width, _liveWindow.frame.size.height)];
    CGPoint offset = CGPointMake(liveWindowRightBottom.x-stickerRect.right, liveWindowRightBottom.y-stickerRect.bottom);

   

    [stickers translateAnimatedSticker:offset];
    
    
}

- (void)removeSticker:(NvsTimeline *)timeline {
    NvsTimelineAnimatedSticker *sticker = [timeline getFirstAnimatedSticker];
    // 删除动画贴纸
    sticker = [timeline removeAnimatedSticker:sticker];
}

- (NSMutableString *)getSticker {
    
    NSString *appPath =[[NSBundle mainBundle] bundlePath];
    
    NSString *stickerFilePath = nil;
    NSString *stickerLicense = nil;
    if ([FSPublishSingleton sharedInstance].isAR) {
        stickerFilePath = [appPath stringByAppendingPathComponent:@"E7A12520-4A53-427E-9E73-986E4635B57C.1.animatedsticker"];
        stickerLicense = [appPath stringByAppendingPathComponent:@"E7A12520-4A53-427E-9E73-986E4635B57C.lic"];
    }
    else {
        stickerFilePath = [appPath stringByAppendingPathComponent:@"A5DF06BA-9A76-4DA1-9F04-6C7BC48C5071.1.animatedsticker"];
        stickerLicense = [appPath stringByAppendingPathComponent:@"A5DF06BA-9A76-4DA1-9F04-6C7BC48C5071.lic"];
    }

    _stickerPackageId = (NSMutableString *)[_context.assetPackageManager getAssetPackageIdFromAssetPackageFilePath:stickerFilePath];
    
    NvsAssetPackageStatus state = [_context.assetPackageManager getAssetPackageStatus:_stickerPackageId type:NvsAssetPackageType_AnimatedSticker];
    
    if (state == NvsAssetPackageStatus_NotInstalled) {
        _stickerPackageId = [[NSMutableString alloc] initWithString:@""];
    }
    else {
        NSArray *assetArray = [_context.assetPackageManager getAssetPackageListOfType:NvsAssetPackageType_AnimatedSticker];
        if ([assetArray containsObject:_stickerPackageId]) {
            return _stickerPackageId;
        }
        else {
            _stickerPackageId = [[NSMutableString alloc] initWithString:@""];
        }
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:stickerFilePath]) {
        NSLog(@"Sticker package file is not exist!");
    } else {
        // 此处选择同步安装，如果包裹过大或者根据需要，可选择异步安装
        NvsAssetPackageManagerError error = [_context.assetPackageManager installAssetPackage:stickerFilePath license:stickerLicense type:NvsAssetPackageType_AnimatedSticker sync:YES assetPackageId:_stickerPackageId];
        if (error != NvsAssetPackageManagerError_NoError && error != NvsAssetPackageManagerError_AlreadyInstalled) {
            NSLog(@"Failed to install sticker package!");
        }
    }

    return _stickerPackageId;
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

- (UIImage *)getImageFromFile:(NSString *)filePath atTime:(int64_t)time videoFrameHeightGrade:(NvsVideoFrameHeightGrade)videoFrameHeightGrade {
    NvsVideoFrameRetriever *retriever = [_context createVideoFrameRetriever:filePath];
    
    return [retriever getFrameAtTime:time videoFrameHeightGrade:videoFrameHeightGrade];
}

- (UIImage *)getImageFromTimeLine:(NvsTimeline *)timeline atTime:(int64_t)time proxyScale:(const NvsRational *)proxyScale {
    return [_context grabImageFromTimeline:timeline timestamp:time proxyScale:proxyScale];
}

#pragma mark - NVConvertorDelegate
- (void)convertFinished {
    [self.mConvertor stop];
    [self.mConvertor close];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });

}

- (void)convertFaild:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderManagerConvertorFaild)]) {
            [self.delegate FSShortVideoRecorderManagerConvertorFaild];
        }
    });
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *final = [documentsDirectory stringByAppendingPathComponent:@"tmp"];
    NSString *tmpfilePath = [final stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[self getCurrentTimeString]]];
    [self convertorWithFile:filePath outPath:tmpfilePath isWebp:NO];
}

- (void)beginCreateWebP:(NSString *)filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *final = [documentsDirectory stringByAppendingPathComponent:@"tmp"];
    
    NSString *tmpfilePath = [final stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.webp",[self getCurrentTimeString]]];
    [self convertorWithFile:filePath outPath:tmpfilePath isWebp:YES];
}

- (void)convertorWithFile:(NSString *)filePath outPath:(NSString *)outPath isWebp:(BOOL)isWebp{
    // 198-14-fecf5c838a33c8b7a27de9790aa3fa96
    NSString *verifySdkLicenseFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"198-14-ec294b7a1c8bbc37aaf8586dcc7cfbf0.lic"];
    
    NSData *JSONData = [NSData dataWithContentsOfFile:verifySdkLicenseFilePath];
    
    BOOL isCanConver = [NvcConvertor InstallLicense:JSONData];
    NSLog(@"verify:setupConvertor %@  %D",verifySdkLicenseFilePath,isCanConver);
    
    if (!isCanConver) {
        [self convertFaild:nil];
    }
   
    _convertorFilePath = outPath;
    
    struct SNvcOutputConfig config ;
    config.from = 0;
    config.to = INT_MAX;
    config.dataRate = 0;
    config.videoResolution = NvcOutputVideoResolution_NotResize;
    config.fpsForWebp = 10;
    
    //倒序
    if (!isWebp) {
        int nTmp = config.from;
        config.from = config.to;
        config.to = nTmp;
    }
    else {
        config.to = 1;
    }
    
    NSInteger ret = [self.mConvertor open:filePath outputFile:outPath setting:&config];
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
- (void)loadAllLocalfxs{

    NSString *verifySdkLicenseFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"198-14-f6192de5110aed067060b4010c648cac.lic"];
    [NvsStreamingContext verifySdkLicenseFile:verifySdkLicenseFilePath];
    _context = [NvsStreamingContext sharedInstanceWithFlags:(NvsStreamingContextFlag_Support4KEdit)];
    
    NSString *SoulfxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"C6273A8F-C899-4765-8BFC-E683EE37AA84.videofx"];
    NSString *SoulfxLicPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"C6273A8F-C899-4765-8BFC-E683EE37AA84.lic"];
    NSString *ScalefxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"A8A4344D-45DA-460F-A18F-C0E2355FE864.videofx"];
    NSString *ScalefxLicPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"A8A4344D-45DA-460F-A18F-C0E2355FE864.lic"];
    NSString *jzfxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"9AC28816-639F-4A9B-B4BA-4060ABD229A2.videofx"];
    NSString *jzfxLicPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"9AC28816-639F-4A9B-B4BA-4060ABD229A2.lic"];
    NSString *jxPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"6B7BE12C-9FA1-4ED0-8E81-E107632FFBC8.videofx"];
    NSString *jxLicPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"6B7BE12C-9FA1-4ED0-8E81-E107632FFBC8.lic"];
    
    NSString *blackMagicPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"33F513E5-5CA2-4C23-A6D4-8466202EE698.videofx"];
    NSString *blackMagicLicPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"33F513E5-5CA2-4C23-A6D4-8466202EE698.lic"];
    
    if ([_context.assetPackageManager getAssetPackageStatus:SoulfxPath type:NvsAssetPackageType_VideoFx] == NvsAssetPackageStatus_NotInstalled) {
        [_context.assetPackageManager installAssetPackage:SoulfxPath license:SoulfxLicPath type:NvsAssetPackageType_VideoFx sync:NO assetPackageId:nil];
    }
    
    if ([_context.assetPackageManager getAssetPackageStatus:ScalefxPath type:(NvsAssetPackageType_VideoFx)] == NvsAssetPackageStatus_NotInstalled) {
        [_context.assetPackageManager installAssetPackage:ScalefxPath license:ScalefxLicPath type:NvsAssetPackageType_VideoFx sync:NO assetPackageId:nil];
    }
    
    if ([_context.assetPackageManager getAssetPackageStatus:jzfxPath type:(NvsAssetPackageType_VideoFx)] == NvsAssetPackageStatus_NotInstalled) {
        [_context.assetPackageManager installAssetPackage:jzfxPath license:jzfxLicPath type:NvsAssetPackageType_VideoFx sync:NO assetPackageId:nil];
    }
    
    if ([_context.assetPackageManager getAssetPackageStatus:jxPath type:(NvsAssetPackageType_VideoFx)] == NvsAssetPackageStatus_NotInstalled) {
        [_context.assetPackageManager installAssetPackage:jxPath license:jxLicPath type:NvsAssetPackageType_VideoFx sync:NO assetPackageId:nil];
    }
    
    if ([_context.assetPackageManager getAssetPackageStatus:blackMagicPath type:(NvsAssetPackageType_VideoFx)] == NvsAssetPackageStatus_NotInstalled) {
        [_context.assetPackageManager installAssetPackage:blackMagicPath license:blackMagicLicPath type:NvsAssetPackageType_VideoFx sync:NO assetPackageId:nil];
    }
}

@end
