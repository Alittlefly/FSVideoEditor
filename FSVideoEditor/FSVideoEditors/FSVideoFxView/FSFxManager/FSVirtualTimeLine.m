//
//  FSVirtualTimeLine.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVirtualTimeLine.h"

@implementation FSVirtualTimeLine

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        self.duration = [[aDecoder decodeObjectForKey:@"duration"] longLongValue];
        self.videoFxs = [aDecoder decodeObjectForKey:@"videoFxs"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:[NSNumber numberWithLongLong:self.duration] forKey:@"duration"];
    [aCoder encodeObject:self.videoFxs forKey:@"videoFxs"];
}

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
    BOOL standardConvert = videoFx.convert;
    // videoFxs 为有序数组
    NSMutableArray *willDealed = [NSMutableArray arrayWithArray:self.videoFxs];
    NSMutableArray *dealedArray = [NSMutableArray array];
    
    for (FSVideoFx *sVideofx in willDealed) {
        // 和标杆不同 就要在时间上反算
        if (sVideofx.convert != standardConvert) {
            //
            int64_t tempStart = sVideofx.startPoint;
            int64_t tempEnd = sVideofx.endPoint;
            sVideofx.startPoint = _duration - tempEnd;
            sVideofx.endPoint = _duration - tempStart;
            sVideofx.convert = standardConvert;
        }
        
        // 统一到一个时间轴上去
        [dealedArray addObject:sVideofx];
    }
    
    //
    NSMutableArray *copyArray = [NSMutableArray arrayWithArray:dealedArray];
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
            newBeforeFx.convert = standardConvert;
        }

        if (videoFx.endPoint < nailfx.endPoint) {
            newAfterFx = [FSVideoFx new];
            newAfterFx.startPoint = videoFx.endPoint;
            newAfterFx.endPoint = nailfx.endPoint;
            newAfterFx.videoFxId = nailfx.videoFxId;
            newAfterFx.convert = standardConvert;

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
