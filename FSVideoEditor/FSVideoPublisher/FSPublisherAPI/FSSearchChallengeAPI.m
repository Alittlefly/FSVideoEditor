//
//  FSSearchChallengeAPI.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSSearchChallengeAPI.h"
#import "AFNetworking.h"
#import "FSVideoEditorCommenData.h"
#import "FSPublishSingleton.h"

@interface FSSearchChallengeAPI()
{
    NSURLSessionTask *_currentTask;
}
@end

@implementation FSSearchChallengeAPI

- (void)searchChallenge:(id)param {
    if (_currentTask) {
        [_currentTask suspend];
        [_currentTask cancel];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakS = self;
    //http://10.10.32.145:8088/video/discover/search?w=
    NSURLSessionTask *task = [manager GET:[NSString stringWithFormat:@"%@video/discover/search",AddressAPI] parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([[responseObject objectForKey:@"code"] integerValue] == 0) {
            if ([weakS.delegate respondsToSelector:@selector(FSSearchChallengeAPISucceed:)]) {
                [weakS.delegate FSSearchChallengeAPISucceed:responseObject];
            }
        }
        else {
            if ([weakS.delegate respondsToSelector:@selector(FSSearchChallengeAPIFailed:)]) {
                [weakS.delegate FSSearchChallengeAPIFailed:nil];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([weakS.delegate respondsToSelector:@selector(FSSearchChallengeAPIFailed:)]) {
            [weakS.delegate FSSearchChallengeAPIFailed:error];
        }
    }];
    
    [task resume];
    _currentTask = task;
}

@end
