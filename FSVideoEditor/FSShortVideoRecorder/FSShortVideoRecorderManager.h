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
- (void)FSShortVideoRecorderManagerFinish:(NvsTimeline *)timeLine;
- (void)FSShortVideoRecorderManagerFailedRecorder;
- (void)FSShortVideoRecorderManagerProgress:(CGFloat)time;
- (void)FSShortVideoRecorderManagerDeleteVideo:(CGFloat)videoTime;
- (void)FSShortVideoRecorderManagerPauseRecorder;
- (void)FSShortVideoRecorderManagerFinishedRecorder:(NSString *)normalFilePath convertFilePath:(NSString *)convertFilePath;
- (void)FSShortVideoRecorderManagerConvertorFinished:(NSString *)filePath;
- (void)FSShortVideoRecorderManagerConvertorFaild;

@end

@interface FSShortVideoRecorderManager : NSObject

@property (nonatomic, weak) id<FSShortVideoRecorderManagerDelegate> delegate;
@property (nonatomic, assign) CGFloat recorderSpeed;
@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic, strong) NSMutableArray *filePathArray;

+ (instancetype)sharedInstance;


/**
 获取预览视图

 @return <#return value description#>
 */
- (NvsLiveWindow *)getLiveWindow;

/**
 初始化预览界面
 */
- (void)initBaseData;

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

/**
 获取所有特效

 @return <#return value description#>
 */
- (NSArray *)getAllVideoFilters;

/**
 添加特效

 @param filter 特效名称
 */
- (void)addFilter:(NSString *)filter;

/**
 获取新的时间线

 @return <#return value description#>
 */
- (NvsTimeline *)createTimeLine;



/**
 视频倒序

 @param filePath 原视频路径
 @return 是否开始执行倒序操作
 */
- (BOOL)beginConvertReverse:(NSString *)filePath;

- (void)beginCreateWebP:(NSString *)filePath;

- (UIImage *)getImageFromFile:(NSString *)filePath atTime:(int64_t)time videoFrameHeightGrade:(NvsVideoFrameHeightGrade)videoFrameHeightGrade;


@end
