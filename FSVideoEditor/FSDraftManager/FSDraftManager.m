//
//  FSDraftManager.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftManager.h"
#import "FSDraftWriter.h"
#import "FSDraftReader.h"
#import "FSDraftCache.h"

@interface FSDraftManager()
@property(nonatomic,strong)FSDraftInfo *currentInfo;
@property(nonatomic,strong)FSDraftReader *reader;
@property(nonatomic,strong)FSDraftWriter *writer;
@end
@implementation FSDraftManager
+(instancetype)sharedManager{
    static id object = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (object == nil) {
            object = [[FSDraftManager alloc] init];
        }
    });
    return object;
}
-(instancetype)init{
    if (self = [super init]) {
        self.reader = [[FSDraftReader alloc] init];
        self.writer = [[FSDraftWriter alloc] init];
    }
    return self;
}
-(void)setCacheKey:(NSString *)cacheKey{
    _cacheKey = cacheKey;
    [[FSDraftCache sharedDraftCache] setCacheKey:cacheKey];
}

-(void)deleteAllDrafts{
    [[FSDraftCache sharedDraftCache] deleteAllLocal];
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
    [self.writer insertLocalDraftInfo:_currentInfo];
}
-(void)cancleOperate{
    _tempInfo = nil;
    _currentInfo = nil;
}
-(void)delete:(FSDraftInfo *)draftInfo{
    [self.writer deleteLocalDraftInfo:draftInfo];
}
-(FSDraftInfo *)draftInfoWithPreInfo:(FSDraftInfo *)preDraftInfo{

    if (_currentInfo == nil) {
        _currentInfo = preDraftInfo?:[[FSDraftInfo alloc] init];
    }
    
    if (!_tempInfo) {
        _tempInfo = [[FSDraftInfo alloc] initWithDraftInfo:preDraftInfo];
    }
    return _tempInfo;
}
-(NSArray *)allDraftInfos{
    NSArray *infos = [self.reader allDraftInfoInLocal];
    return infos;
}
-(void)logoutDraftWithCacheKey{
    [self setCacheKey:nil];
    [self.reader clearMemoryDrafts];
}

@end
