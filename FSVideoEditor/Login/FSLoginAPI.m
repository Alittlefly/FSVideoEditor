//
//  FSLoginAPI.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSLoginAPI.h"
#import "AFNetworking.h"
#import "FSVideoEditorCommenData.h"


@interface FSLoginAPI() {
    NSURLSessionTask *_currentTask;
}

@end

@implementation FSLoginAPI

- (void)loginWithParam:(id)param {
    if (_currentTask) {
        [_currentTask suspend];
        [_currentTask cancel];
    }
    
//    "_v" = "4.5.0";
//    base = base;
//    checkcode = "";
//    date = 1499258666113;
//    email = "Test15@qq.com";
//    fromType = 1;
//    loginName = "Test15@qq.com";
//    machineId = "3007FEDB-FC52-4B9F-AA80-4B434EA77CCB";
//    machineType = "iPhone5s(A1457/A1518/A1528/A1530)";
//    nickName = "";
//    password = 111111;
//    requestType = 4;
//    sex = 0;
//    tokenSecret = "";
//    validatekey = "3007FEDB-FC52-4B9F-AA80-4B434EA77CCB";

    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    __weak typeof(self) weakS = self;
    NSString *address = [NSString stringWithFormat:@"%@service/user/v3/login/mobile/v4",AddressAPILogin];
    NSURLSessionTask *task = [manager POST:address parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if ([weakS.delegate respondsToSelector:@selector(FSLoginAPISecceed:)]) {
                [weakS.delegate FSLoginAPISecceed:responseObject];
            }
        }
        else {
            if ([weakS.delegate respondsToSelector:@selector(FSLoginAPIFaild:)]) {
                [weakS.delegate FSLoginAPIFaild:nil];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([weakS.delegate respondsToSelector:@selector(FSLoginAPIFaild:)]) {
            [weakS.delegate FSLoginAPIFaild:error];
        }
    }];
    
    [task resume];
    _currentTask = task;
}

@end
