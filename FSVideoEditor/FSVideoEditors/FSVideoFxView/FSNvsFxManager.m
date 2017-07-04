//
//  FSNvsFxManager.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/4.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSNvsFxManager.h"
@interface FSNvsFxManager()
@property(nonatomic,strong)NSMutableArray *videoFxQueue;
@end
@implementation FSNvsFxManager
-(NSMutableArray *)videoFxQueue{
    if (!_videoFxQueue) {
        _videoFxQueue = [NSMutableArray array];
    }
    return _videoFxQueue;
}
-(FSVideoFx *)popVideoFx{
    
    FSVideoFx *topVideoFx = nil;
    if ([self.videoFxQueue count]) {
         topVideoFx = [self.videoFxQueue lastObject];
        [self.videoFxQueue removeLastObject];
    }
    return topVideoFx;
}
-(void)pushVideoFx:(FSVideoFx *)videoFx{
    if (videoFx != nil) {
        [self.videoFxQueue addObject:videoFx];
    }
}
-(FSVideoFx *)topVideoFx{
    if (![self.videoFxQueue count]) {
        return nil;
    }
    
    return [self.videoFxQueue lastObject];
}
-(void)popAll{
    [self.videoFxQueue removeAllObjects];
}
-(NSArray *)allVideoFx{
    NSArray *all = [NSArray arrayWithArray:self.videoFxQueue];
    return all;
}
-(void)pushVideoFxFromManager:(FSNvsFxManager *)manager{
    NSArray *all = [[manager allVideoFx] reverseObjectEnumerator].allObjects;
    [self.videoFxQueue addObjectsFromArray:all];
}

@end

@implementation FSVideoFx

@end
