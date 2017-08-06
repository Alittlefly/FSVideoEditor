//
//  FSShortVideoRecorderView.h
//  7nujoom
//
//  Created by 王明 on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSDraftInfo.h"

@class NvsTimeline;

typedef enum{
    FSShortVideoPlaySpeed_Hyperslow = 0,
    FSShortVideoPlaySpeed_Slow,
    FSShortVideoPlaySpeed_Normal,
    FSShortVideoPlaySpeed_Quick,
    FSShortVideoPlaySpeed_VeryFast
}FSShortVideoPlaySpeed;

@protocol FSShortVideoRecorderViewDelegate <NSObject>

- (void)FSShortVideoRecorderViewQuitRecorderView;
- (void)FSShortVideoRecorderViewFinishRecorder:(NSString *)filePath speed:(CGFloat)speed musicStartTime:(NSTimeInterval)time;
- (void)FSShortVideoRecorderViewFinishRecorder:(NSString *)filePath convertFilePath:(NSString *)convertFilePath speed:(CGFloat)speed musicStartTime:(NSTimeInterval)time;
- (void)FSShortVideoRecorderViewFinishTimeLine:(NvsTimeline *)timeLine speed:(CGFloat)speed musicStartTime:(NSTimeInterval)time;
- (void)FSShortVideoRecorderViewEditMusic;
- (void)FSShortVideoRecorderViewShowAlertView:(NSString *)message;
- (void)FSShortVideoRecorderViewShowFilterView;

@end

@interface FSShortVideoRecorderView : UIView

@property (nonatomic, weak) id<FSShortVideoRecorderViewDelegate> delegate;
@property (nonatomic, copy) NSString *musicFilePath;
@property (nonatomic, assign) NSTimeInterval musicStartTime;
@property (nonatomic, strong) FSDraftInfo *draftInfo;

- (void)resumeCapturePreview;
- (void)changeFilter:(NSString *)filterName;
- (void)finishChangeFilter;

@end
