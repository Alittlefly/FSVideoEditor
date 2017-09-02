//
//  FSVideoEditorAPIParams.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoEditorAPIParams.h"
#import "FSPublishSingleton.h"

@implementation FSVideoEditorAPIParams
+(instancetype)videoEdiorParams{
    FSVideoEditorAPIParams *params = [[FSVideoEditorAPIParams alloc] init];
    return params;
}
-(instancetype)init{
    static id object = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (object == nil) {
            object = [super init];
        }
    });
    return object;
}
-(NSMutableDictionary *)params{
    if (!_params) {
         _params = [NSMutableDictionary dictionary];
        [_params setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:@"_v"];
        [_params setValue:@"4" forKey:@"requestType"];
        [_params setValue:[FSPublishSingleton sharedInstance].loginKey forKey:@"loginKey"];
    }
    return _params;
}
@end
