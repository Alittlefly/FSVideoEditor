//
//  FSMusicAPI.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicAPI.h"
#import "AFNetworking.h"
@interface FSMusicAPI()
{
    NSURLSessionTask *_currentTask;
}
@end
@implementation FSMusicAPI
-(void)getMusicWithParam:(id)param{
    if (_currentTask) {
        [_currentTask suspend];
        [_currentTask cancel];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakS = self;
    NSURLSessionTask *task = [manager GET:@"http://10.10.32.145:8088/video/song/use/3" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([weakS.delegate respondsToSelector:@selector(musicApiGetMusics:)]) {
            [weakS.delegate musicApiGetMusics:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    [task resume];
    _currentTask = task;
}
-(void)cancleTask{
    [_currentTask cancel];
}
@end
