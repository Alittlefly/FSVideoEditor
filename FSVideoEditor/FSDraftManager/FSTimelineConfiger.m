//
//  FSTimelineConfiger.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSTimelineConfiger.h"

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
            [timeLine addPackagedTimelineVideoFx:startTime duration:duration videoFxPackageId:fx.videoFxId];
        }
    }
    
    // 设置TimeFx
}

@end
