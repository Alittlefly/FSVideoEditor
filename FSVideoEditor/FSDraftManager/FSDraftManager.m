//
//  FSDraftManager.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftManager.h"

@implementation FSDraftManager
+(instancetype)sharedDraftManager{
    static id object = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (object == nil) {
            object = [[FSDraftManager alloc] init];
        }
    });
    return object;
}
-(FSDraftInfo *)tempTimeLineInfoWithPreInfo:(FSDraftInfo *)timeLineInfo{
    return nil;
}
-(void)clearInfo{}
-(void)mergeInfo{}
-(void)saveToLocal{}
-(void)cancleOperate{}
-(void)delete:(FSDraftInfo *)draftInfo{}
-(FSDraftInfo *)draftInfoWithPreInfo:(FSDraftInfo *)preDraftInfo{
    return nil;
}
@end
