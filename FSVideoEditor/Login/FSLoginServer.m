//
//  FSLoginServer.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSLoginServer.h"
#import "FSLoginAPI.h"

@interface FSLoginServer()<FSLoginAPIDelegate>

@end

@implementation FSLoginServer

- (void)loginWithUid:(NSString *)uid password:(NSString *)password {
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:@"Test12@qq.com" forKey:@"email"];
    [dic setValue:@"111111" forKey:@"password"];
    [dic setValue:@"4.5.0" forKey:@"_v"];
    [dic setValue:@"base" forKey:@"base"];
    [dic setValue:@"1" forKey:@"fromType"];
    [dic setValue:@"3007FEDB-FC52-4B9F-AA80-4B434EA77CCB" forKey:@"machineId"];
    [dic setValue:@"iPhone5s(A1457/A1518/A1528/A1530)" forKey:@"machineType"];
    [dic setValue:@"4" forKey:@"requestType"];

   // [dic setValue:@"3007FEDB-FC52-4B9F-AA80-4B434EA77CCB" forKey:@"validatekey"];


    
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
    
    FSLoginAPI *api = [[FSLoginAPI alloc] init];
    api.delegate = self;
    [api loginWithParam:dic];
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
