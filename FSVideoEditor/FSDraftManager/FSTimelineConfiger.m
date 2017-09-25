//
//  FSTimelineConfiger.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSTimelineConfiger.h"
#import "NvsVideoTrack.h"
#import "FSShortVideoRecorderManager.h"
#import "NvsVideoClip.h"

@implementation FSTimelineConfiger
+(void)configTimeline:(NvsTimeline *)timeLine timeLineInfo:(FSDraftInfo *)timeLineInfo{
    // 添加特效
    if (timeLineInfo.stack) {
        FSVideoFxOperationStack *stack = timeLineInfo.stack;
        FSVirtualTimeLine *timeLineFxs = [stack topVirtualTimeLine];
        
        NSArray *videoFxs = [timeLineFxs allVideoFxs];
        for (FSVideoFx *fx in videoFxs) {
            
            int64_t startTime = fx.startPoint;
            int64_t duration = fx.endPoint - fx.startPoint;
            
            if(fx.convert != (timeLineInfo.vTimefx.tFxType == FSVideoFxTypeRevert)){
                // 不能对应当前轨道的特效 那就翻转
                startTime = timeLine.duration - fx.endPoint;
            }
            
            if ([fx.videoFxId isEqualToString:@"Video Echo"])
                [timeLine addBuiltinTimelineVideoFx:startTime duration:duration videoFxName:fx.videoFxId];
            else{
                [timeLine addPackagedTimelineVideoFx:startTime duration:duration videoFxPackageId:fx.videoFxId];
                
            }
        }
    }
    [FSTimelineConfiger addTimeFxWithFx:timeLineInfo.vTimefx timeLine:timeLine];
    
   // if (timeLineInfo.vFilterid != nil) {
       //  [FSTimelineConfiger addFilter:timeLineInfo.vFilterid timeLine:timeLine];
   // }
}
+(void)addFilter:(NSString *)filter timeLine:(NvsTimeline *)timeLine{
    
    NvsVideoTrack *_videoTrack = [timeLine getVideoTrackByIndex:0];
    if ([filter isEqualToString:@"NoFilter"]) {
        for (unsigned int i = 0; i < _videoTrack.clipCount; i++){
            [[_videoTrack getClipWithIndex:i] removeAllFx];
        }
    } else if ([filter isEqualToString:@"Package1"]) {
        for (unsigned int i = 0; i < _videoTrack.clipCount; i++) {
            NvsVideoClip *videoClip = [_videoTrack getClipWithIndex:i];
            [[FSShortVideoRecorderManager sharedInstance] addFilter:filter toVideoClip:videoClip];
        }
    } else {
        for (unsigned int i = 0; i < _videoTrack.clipCount; i++) {
            NvsVideoClip *videoClip = [_videoTrack getClipWithIndex:i];
            [[FSShortVideoRecorderManager sharedInstance] addFilter:filter toVideoClip:videoClip];
        }
    }
}
+(void)addTimeFxWithFx:(FSDraftTimeFx *)timeFx timeLine:(NvsTimeline *)timeLine{
    //
    FSVideoFxType type = timeFx.tFxType;
    
    int64_t fxPos = timeFx.tFxInPoint;
    int64_t duration = timeFx.tFxOutPoint - timeFx.tFxInPoint;

    NvsVideoTrack* _videoTrack = [timeLine getVideoTrackByIndex:0];
    int64_t originalDuration = timeLine.duration;

    if (type == FSVideoFxTypeSlow) {
        //缓慢
        NvsVideoClip* newClip = [FSTimelineConfiger splitClip:fxPos duration:duration timeLine:timeLine];
        [newClip changeSpeed:0.5*newClip.getSpeed];
        
    }else if(type == FSVideoFxTypeRepeat){
        // 重复
        NvsVideoClip* newClip = [FSTimelineConfiger splitClip:fxPos duration:duration timeLine:timeLine];
        
        for (int i=0; i<2; i++) {
            NvsVideoClip* clip = [_videoTrack insertClip:newClip.filePath trimIn:newClip.trimIn trimOut:newClip.trimOut clipIndex:newClip.index];
            if (clip != nil)
                [clip changeSpeed:newClip.getSpeed*0.5];
        }
        
        for (int i=0; i<_videoTrack.clipCount-1; i++)
            [_videoTrack setBuiltinTransition:i withName:nil];
    }
    
    int64_t currentDuration = timeLine.duration;
    if (currentDuration > originalDuration) {
        NvsVideoClip *trailClip = [_videoTrack getClipWithTimelinePosition:originalDuration];
        int64_t shouldBeTrimOut = trailClip.trimOut - (currentDuration - originalDuration);
        [trailClip changeTrimOutPoint:shouldBeTrimOut affectSibling:YES];
        
    }
    
    [_videoTrack setVolumeGain:0 rightVolumeGain:0];
    
}

+ (NvsVideoClip*) splitClip:(int64_t)fxPoint duration:(int64_t)duration timeLine:(NvsTimeline *)timeLine{
    
    bool tailer = false;
    int64_t fxPos = fxPoint;
    NvsVideoTrack* _videoTrack = [timeLine getVideoTrackByIndex:0];

    if (timeLine.duration-fxPos <= duration) {
        fxPos = timeLine.duration - duration;
        tailer = true;
    }
    if (![_videoTrack splitClip:[_videoTrack getClipWithTimelinePosition:fxPos].index splitPoint:fxPos])
        return nil;
    if (!tailer) {
        if (![_videoTrack splitClip:[_videoTrack getClipWithTimelinePosition:fxPos+duration].index splitPoint:fxPos+duration])
            return nil;
    }
    NvsVideoClip* newClip = [_videoTrack getClipWithTimelinePosition:fxPos];
    return newClip;
}
@end
