//
//  FSShortVideoRecorderManager.m
//  7nujoom
//
//  Created by 王明 on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSShortVideoRecorderManager.h"

@interface FSShortVideoRecorderManager ()<NvsStreamingContextDelegate>

@property (nonatomic, strong) NvsLiveWindow *liveWindow;


@end

static FSShortVideoRecorderManager *recorderManager;

@implementation FSShortVideoRecorderManager {
    NvsStreamingContext *_context;
    
    unsigned int _currentDeviceIndex;
    
    bool _supportAutoFocus;
    bool _supportAutoExposure;
}


+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recorderManager = [[FSShortVideoRecorderManager alloc] init];
    });
    return recorderManager;
}

- (NvsLiveWindow *)liveWindow {
    if (!_liveWindow) {
        _liveWindow = [[NvsLiveWindow alloc] init];
        //        _liveWindow.backgroundColor = [UIColor blueColor];
    }
    return _liveWindow;
}

- (instancetype)init {
    if (self = [super init]) {
        _currentDeviceIndex = 0;
        _supportAutoFocus = false;
        _supportAutoExposure = false;
        
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
    return self;
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

#pragma mark - NvsStreamingContextDelegate
- (void)didCaptureDeviceCapsReady:(unsigned int)captureDeviceIndex {
    if (captureDeviceIndex != _currentDeviceIndex) {
        return;
    }
    
    [self updateSettingWithCapability:captureDeviceIndex];
}

@end
