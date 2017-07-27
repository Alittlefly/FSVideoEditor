//
//  FSVideoEditorAPIParams.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoEditorAPIParams.h"

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
    }
    return _params;
}
@end
