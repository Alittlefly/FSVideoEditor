//
//  FSLoginServer.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSLoginServer.h"
#import "FSLoginAPI.h"
#import <UIKit/UIKit.h>

@interface FSLoginServer()<FSLoginAPIDelegate>

@property (nonatomic, strong) FSLoginAPI *loginAPI;

@end

@implementation FSLoginServer

- (void)loginWithUid:(NSString *)uid password:(NSString *)password {
    NSDate *curDate = [NSDate date];
    NSTimeInterval curTime = [curDate timeIntervalSince1970]*1000;
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:uid forKey:@"email"];
    [dic setValue:password forKey:@"password"];
    [dic setValue:@"4.5.2" forKey:@"_v"];
    [dic setValue:@"base" forKey:@"base"];
    [dic setValue:[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:floor(curTime)]] forKey:@"date"];
    [dic setValue:[NSNumber numberWithInteger:1] forKey:@"fromType"];
    [dic setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"machineId"];
    [dic setValue:@"" forKey:@"machineType"];
    [dic setValue:[NSNumber numberWithInteger:4] forKey:@"requestType"];
    [dic setValue:uid forKey:@"loginName"];

    [dic setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"validatekey"];


    
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
    if (!_loginAPI) {
        _loginAPI = [[FSLoginAPI alloc] init];
        _loginAPI.delegate = self;
    }
    
    [_loginAPI loginWithParam:dic];
}

#pragma mark - FSLoginAPIDelegate
- (void)FSLoginAPISecceed:(id)objec {
    if ([self.delegate respondsToSelector:@selector(FSLoginServerSucceed:)]) {
        [self.delegate FSLoginServerSucceed:objec];
    }
}

- (void)FSLoginAPIFaild:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(FSLoginServerFaild:)]) {
        [self.delegate FSLoginServerFaild:error];
    }
}

@end
