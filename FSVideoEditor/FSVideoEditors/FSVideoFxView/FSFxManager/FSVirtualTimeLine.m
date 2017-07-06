//
//  FSVirtualTimeLine.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVirtualTimeLine.h"

@implementation FSVirtualTimeLine
-(NSMutableArray *)videoFxs{
    if (!_videoFxs) {
        _videoFxs  = [NSMutableArray array];
    }
    return _videoFxs;
}

-(void)addVideoFx:(FSVideoFx *)videoFx{
    if (!videoFx) {
        return;
    }
    //
    NSMutableArray *copyArray = [NSMutableArray arrayWithArray:self.videoFxs];
    
    NSMutableArray *before = [NSMutableArray array];
    NSMutableArray *after = [NSMutableArray array];
    
    // 处理前边 和 后边的
    for (NSInteger index = 0; index < [self.videoFxs count]; index ++) {
        FSVideoFx *sFx = [self.videoFxs objectAtIndex:index];
        // 前边的
        if (sFx.endPoint <= videoFx.startPoint) {
            [before addObject:sFx];
        }
        // 后边的
        if (sFx.startPoint >= videoFx.endPoint) {
            [after addObject:sFx];
        }
    }
    // 切割
    [copyArray removeObjectsInArray:before];
    [copyArray removeObject:after];
    
    NSArray *centerArray = [NSArray arrayWithArray:copyArray];
    
    NSMutableArray *reflects = [NSMutableArray array];
    // copy 内剩余 中间影响的部分
    if (![centerArray count]) {
        // 正好分完中间没有
        [reflects addObject:videoFx];
    }else{
        // 中间有
        // 第一个
        FSVideoFx * headfx = [centerArray firstObject];
        // 最后一个
        FSVideoFx * nailfx = [centerArray lastObject];
        // 可能要拆分
        FSVideoFx *newBeforeFx = nil;
        FSVideoFx *newAfterFx = nil;
    
        if (videoFx.startPoint > headfx.startPoint) {
            newBeforeFx =  [FSVideoFx new];
            newBeforeFx.startPoint = headfx.startPoint;
            newBeforeFx.endPoint = videoFx.startPoint;
            newBeforeFx.videoFxId = headfx.videoFxId;
        }

        if (videoFx.endPoint < nailfx.endPoint) {
            newAfterFx = [FSVideoFx new];
            newAfterFx.startPoint = videoFx.endPoint;
            newAfterFx.endPoint = nailfx.endPoint;
            newAfterFx.videoFxId = nailfx.videoFxId;
        }

        if (newBeforeFx) {
            [reflects addObject:newBeforeFx];
        }
        [reflects addObject:videoFx];
        
        if (newAfterFx) {
            [reflects addObject:newAfterFx];
        }
    }
    
    // 最终结果
    NSMutableArray *final = [NSMutableArray array];
    [final addObjectsFromArray:before];
    [final addObjectsFromArray:reflects];
    [final addObjectsFromArray:after];
    //
    [self.videoFxs removeAllObjects];
    [self.videoFxs addObjectsFromArray:final];
}
-(void)addVideoFxsInArray:(NSArray *)fxs{
    
    for (FSVideoFx *videoFx in fxs) {
        [self.videoFxs addObject:[videoFx copy]];
    }
}
-(NSArray *)allVideoFxs{
    return [NSArray arrayWithArray:self.videoFxs];
}
@end


//////////////////////////////// 拆分逻辑 ////////////////////////////////////////
//
//
//
//
//
//
//        if ([headfx isEqual:nailfx]) {
//            // @ 2 分割后只剩一个
//            if (videoFx.startPoint > headfx.startPoint) {
//                //
//                newBeforeFx = [FSVideoFx new];
//                newBeforeFx.startPoint = videoFx.startPoint;
//                newBeforeFx.endPoint = headfx.startPoint;
//                newBeforeFx.videoFxId = headfx.videoFxId;
//            }
//
//            if (videoFx.endPoint < headfx.endPoint) {
//                newAfterFx = [FSVideoFx new];
//                newAfterFx.startPoint = videoFx.endPoint;
//                newAfterFx.endPoint = headfx.endPoint;
//                newAfterFx.videoFxId = headfx.videoFxId;
//            }

//            @  1
//            if (videoFx.startPoint > headfx.startPoint && videoFx.endPoint < headfx.endPoint) {
//                newBeforeFx = [FSVideoFx new];
//                newBeforeFx.startPoint = videoFx.startPoint;
//                newBeforeFx.endPoint = headfx.startPoint;
//                newBeforeFx.videoFxId = headfx.videoFxId;
//
//                newAfterFx = [FSVideoFx new];
//                newAfterFx.startPoint = videoFx.endPoint;
//                newAfterFx.endPoint = headfx.endPoint;
//                newAfterFx.videoFxId = headfx.videoFxId;
//
//            }else if (videoFx.startPoint <= headfx.startPoint && videoFx.endPoint < headfx.endPoint){
//                newAfterFx = [FSVideoFx new];
//                newAfterFx.startPoint = videoFx.endPoint;
//                newAfterFx.endPoint = headfx.endPoint;
//                newAfterFx.videoFxId = headfx.videoFxId;
//
//            }else if (videoFx.startPoint > headfx.startPoint && videoFx.endPoint >= headfx.endPoint){
//                newBeforeFx = [FSVideoFx new];
//                newBeforeFx.startPoint = videoFx.startPoint;
//                newBeforeFx.endPoint = headfx.startPoint;
//                newBeforeFx.videoFxId = headfx.videoFxId;
//            }
//        }else{
// @ 2
//            if (videoFx.startPoint > headfx.startPoint) {
//                newBeforeFx =  [FSVideoFx new];
//                newBeforeFx.startPoint = headfx.startPoint;
//                newBeforeFx.endPoint = videoFx.startPoint;
//                newBeforeFx.videoFxId = headfx.videoFxId;
//            }
//
//            if (videoFx.endPoint < nailfx.endPoint) {
//                newAfterFx = [FSVideoFx new];
//                newAfterFx.startPoint = videoFx.endPoint;
//                newAfterFx.endPoint = nailfx.endPoint;
//                newAfterFx.videoFxId = nailfx.videoFxId;
//            }

//  @ 1分割后还有多个 找出前后的位置的分段
//            if (videoFx.startPoint > headfx.startPoint && videoFx.endPoint < nailfx.endPoint) {
//                newBeforeFx =  [FSVideoFx new];
//                newBeforeFx.startPoint = headfx.startPoint;
//                newBeforeFx.endPoint = videoFx.startPoint;
//                newBeforeFx.videoFxId = headfx.videoFxId;
//
//                newAfterFx = [FSVideoFx new];
//                newAfterFx.startPoint = videoFx.endPoint;
//                newAfterFx.endPoint = nailfx.endPoint;
//                newAfterFx.videoFxId = nailfx.videoFxId;
//            }else if(videoFx.startPoint <= headfx.startPoint && videoFx.endPoint < nailfx.endPoint){
//                newAfterFx = [FSVideoFx new];
//                newAfterFx.startPoint = videoFx.endPoint;
//                newAfterFx.endPoint = nailfx.endPoint;
//                newAfterFx.videoFxId = nailfx.videoFxId;
//            }else if (videoFx.startPoint > headfx.startPoint && videoFx.endPoint >=  nailfx.endPoint ){
//                newBeforeFx =  [FSVideoFx new];
//                newBeforeFx.startPoint = headfx.startPoint;
//                newBeforeFx.endPoint = videoFx.startPoint;
//                newBeforeFx.videoFxId = headfx.videoFxId;
//            }
//        }
