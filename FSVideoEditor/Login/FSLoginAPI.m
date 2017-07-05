//
//  FSLoginAPI.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSLoginAPI.h"
#import "AFNetworking.h"

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
    
    //[_loginUserSever loginUserWithName:name password:pwd sex:nil birthday:nil profileImage:nil email:name base:@"base" FromType:@"1" nickName:@"" pinCode:_loginView.pinCode thirdToken:nil tokenSecret:nil];
//    FSUserLoginParam *param = [[FSUserLoginParam alloc] init];
//    [param setLoginName:name];
//    [param setPassword:pwd];
//    [param setCheckcode:pinCode];
//    [param setToken:token];
//    [param setTokenSecret:tokenSecret?:@""];
//    
//    if (sex != nil) {
//        if ([sex isEqualToString:@"male"] || [sex isEqualToString:@"Male"]) {
//            // [dic setObject:[NSNumber numberWithInt:1] forKey:@"sex"];
//            [param setSex:1];
//        }
//        else if ([sex isEqualToString:@"female"] || [sex isEqualToString:@"Female"]) {
//            [param setSex:2];
//        }
//    }
//    [param setBirthday:birthday];
//    [param setFromType:fromType];
//    [param setProfileImage:profileImage];
//    [param setEmail:email];
//    
//    [param setBase:base];
//    [param setNickName:nickName];
//    [param setValidatekey:[param validatekey]];

    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakS = self;
    NSString *address = @"http://10.10.32.152:9999/service/user/v3/login/mobile/v4";
    NSURLSessionTask *task = [manager GET:address parameters:nil progress:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([weakS.delegate respondsToSelector:@selector(FSLoginAPISecceed:)]) {
            [weakS.delegate FSLoginAPISecceed:responseObject];
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
