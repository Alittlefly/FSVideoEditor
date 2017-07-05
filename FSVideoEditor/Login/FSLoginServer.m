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
    [dic setValue:uid forKey:@"uid"];
    [dic setValue:password forKey:@"psd"];
    
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
