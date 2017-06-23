//
//  FSShortVideoRecorderManager.h
//  7nujoom
//
//  Created by 王明 on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsStreamingContext.h"

@protocol FSShortVideoRecorderManagerDelegate <NSObject>

- (void)FSShortVideoRecorderManagerFinishRecorder:(NSString *)filePath;
- (void)FSShortVideoRecorderManagerFailedRecorder;

@end

@interface FSShortVideoRecorderManager : NSObject

@property (nonatomic, weak) id<FSShortVideoRecorderManagerDelegate> delegate;

+ (instancetype)sharedInstance;


/**
 获取预览视图

 @return <#return value description#>
 */
- (NvsLiveWindow *)getLiveWindow;

/**
 切换摄像头

 @return <#return value description#>
 */
- (BOOL)switchCamera;

/**
 切换闪光灯

 @param on <#on description#>
 */
- (void)switchFlash:(BOOL)on;

/**
 美颜开关

 @param on <#on description#>
 */
- (void)switchBeauty:(BOOL)on;

- (void)startAutoFocus:(CGPoint)point;

- (void)startAutiExposure:(CGPoint)point;

- (BOOL)isSupportAutoFocus;

- (BOOL)isSupportAutoExposure;

- (void)startRecording:(NSString *)filePath;

- (void)stopRecording;
- (BOOL)finishRecorder;
- (BOOL)deleteVideoFile;
- (void)resumeCapturePreview;
- (NSString *)getVideoPath;
- (void)quitRecording;

@end
