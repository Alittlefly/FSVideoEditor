//
//  FSPublisherAPI.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/7.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSPublisherAPI.h"
#import "AFNetworking.h"
#import "FSVideoEditorCommenData.h"


@interface FSPublisherAPI()
{
    NSURLSessionTask *_currentTask;
}
@end

@implementation FSPublisherAPI

- (void)publisherVideo:(id)param {
    if (_currentTask) {
        [_currentTask suspend];
        [_currentTask cancel];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakS = self;
    //http://10.10.32.145:8088/video/index/publish/video  http://www.7nujoom.com/
    NSURLSessionTask *task = [manager POST:[NSString stringWithFormat:@"%@video/index/publish/video",AddressAPI] parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([weakS.delegate respondsToSelector:@selector(FSPublisherAPISucceed)]) {
            [weakS.delegate FSPublisherAPISucceed];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([weakS.delegate respondsToSelector:@selector(FSPublisherAPIFailed:)]) {
            [weakS.delegate FSPublisherAPIFailed:error];
        }
    }];
    
    [task resume];
    _currentTask = task;
}
-(void)cancleTask{
    [_currentTask cancel];
}


@end
