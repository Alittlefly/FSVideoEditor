//
//  FSAddChallengeAPI.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/26.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSAddChallengeAPI.h"
#import "AFNetworking.h"
#import "FSVideoEditorCommenData.h"

@interface FSAddChallengeAPI()
{
    NSURLSessionTask *_currentTask;
}
@end

@implementation FSAddChallengeAPI

- (void)addNewChallenge:(id)param {
    if (_currentTask) {
        [_currentTask suspend];
        [_currentTask cancel];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakS = self;
    //http://10.10.32.145:8088/video/discover/search?w=
    NSURLSessionTask *task = [manager POST:[NSString stringWithFormat:@"%@video/discover/add",AddressAPI] parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        if (code == 0) {
            if ([weakS.delegate respondsToSelector:@selector(FSAddChallengeAPIAddChallengeSucceed:)]) {
                [weakS.delegate FSAddChallengeAPIAddChallengeSucceed:responseObject];
            }
        }
        else {
            if ([weakS.delegate respondsToSelector:@selector(FSAddChallengeAPIAddChallengeFailed:)]) {
                [weakS.delegate FSAddChallengeAPIAddChallengeFailed:nil];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([weakS.delegate respondsToSelector:@selector(FSAddChallengeAPIAddChallengeFailed:)]) {
            [weakS.delegate FSAddChallengeAPIAddChallengeFailed:error];
        }
    }];
    
    [task resume];
    _currentTask = task;
}

@end
