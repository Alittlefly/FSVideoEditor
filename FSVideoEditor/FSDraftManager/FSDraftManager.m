//
//  FSDraftManager.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftManager.h"
#import "FSDraftWriter.h"

@interface FSDraftManager()
@property(nonatomic,strong)FSDraftInfo *currentInfo;
@property(nonatomic,strong)FSDraftInfo *tempInfo;
@end
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
-(void)clearInfo{
    _tempInfo = nil;
}
-(void)mergeInfo{
    if (_tempInfo == nil) {
        return;
    }
    [_currentInfo copyValueFromeDraftInfo:_tempInfo];
}
-(void)saveToLocal{
    FSDraftWriter *writer = [FSDraftWriter new];
    [writer insertLocalDraftInfo:_currentInfo];
}
-(void)cancleOperate{
    _tempInfo = nil;
    _currentInfo = nil;
}
-(void)delete:(FSDraftInfo *)draftInfo{
    FSDraftWriter *writer = [FSDraftWriter new];
    [writer deleteLocalDraftInfo:_currentInfo];
}
-(FSDraftInfo *)draftInfoWithPreInfo:(FSDraftInfo *)preDraftInfo{
    _currentInfo = preDraftInfo;
    
    if (_currentInfo == nil) {
        _currentInfo = [FSDraftInfo new];
    }
    
    if (!_tempInfo) {
        _tempInfo = [[FSDraftInfo alloc] initWithDraftInfo:preDraftInfo];
    }
    return _tempInfo;
}
@end
