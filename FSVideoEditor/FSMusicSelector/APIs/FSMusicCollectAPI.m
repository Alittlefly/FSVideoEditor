//
//  FSMusicCollectAPI.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicCollectAPI.h"
#import "AFNetworking.h"
#import "FSVideoEditorCommenData.h"
#import "FSVideoEditorAPIParams.h"
#import "FSPublishSingleton.h"

@interface FSMusicCollectAPI()
{
    NSURLSessionTask *_currentTask;
}
@end
@implementation FSMusicCollectAPI

-(void)collectMusic:(NSInteger)musicId collect:(BOOL)collect{
    if (_currentTask) {
        [_currentTask suspend];
        [_currentTask cancel];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakS = self;
    NSDictionary *params = [NSDictionary dictionaryWithDictionary:[FSVideoEditorAPIParams videoEdiorParams].params];
    NSLog(@"collectMusic:%@",params);
    NSURLSessionTask *task = [manager GET:[NSString stringWithFormat:@"%@video/song/%ld/%d",AddressAPI,musicId,collect] parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"collectMusic:%@",responseObject);
        NSInteger code = [[responseObject valueForKey:@"code"] integerValue];
        if (code == 0) {
            if ([weakS.delegate respondsToSelector:@selector(collectMusicSuccess:)]) {
                [weakS.delegate collectMusicSuccess:weakS];
            }
        }else{
            if ([weakS.delegate respondsToSelector:@selector(collectMusicFaild:)]) {
                [weakS.delegate collectMusicFaild:weakS];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([weakS.delegate respondsToSelector:@selector(collectMusicFaild:)]) {
            [weakS.delegate collectMusicFaild:weakS];
        }
    }];
    
    [task resume];
    _currentTask = task;
    
    [self setTaskId:[NSString stringWithFormat:@"%ld",task.taskIdentifier]];
}
-(void)cancleTask{
    [_currentTask cancel];
}


-(void)dealloc{
    NSLog(@"FSMusicCollectAPI delloc");
}
@end
