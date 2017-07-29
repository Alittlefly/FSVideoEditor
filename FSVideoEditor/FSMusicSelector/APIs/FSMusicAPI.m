//
//  FSMusicAPI.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicAPI.h"
#import "AFNetworking.h"
#import "FSVideoEditorCommenData.h"
@interface FSMusicAPI()
{
    NSURLSessionTask *_currentTask;
}
@end
@implementation FSMusicAPI
-(void)getMusicWithPage:(NSInteger)page{
    if (_currentTask) {
        [_currentTask suspend];
        [_currentTask cancel];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakS = self;
    //http://10.10.32.145:8088/   http://www.7nujoom.com/
    NSURLSessionTask *task = [manager GET:[NSString stringWithFormat:@"%@video/song/list?no=%ld&size=5",AddressAPI,page] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([weakS.delegate respondsToSelector:@selector(musicApiGetMusics:)]) {
            [weakS.delegate musicApiGetMusics:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([weakS.delegate respondsToSelector:@selector(musicApiGetMusicsFaild:)]) {
            [weakS.delegate musicApiGetMusicsFaild:error];
        }
    }];
    
    [task resume];
    _currentTask = task;
}
-(void)cancleTask{
    [_currentTask cancel];
}
@end
