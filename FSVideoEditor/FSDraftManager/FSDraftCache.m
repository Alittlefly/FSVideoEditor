//
//  FSDraftCache.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftCache.h"
#import "FSDraftFileManager.h"


@interface FSDraftCache()
@property(nonatomic,strong)NSMutableArray *draftInfos;
@end
@implementation FSDraftCache
-(NSMutableArray *)draftInfos{
    if (!_draftInfos) {
        _draftInfos = [NSMutableArray array];
    }
    return _draftInfos;
}
+(instancetype)sharedDraftCache{
    static id object = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (object == nil) {
            object = [[FSDraftInfo alloc] init];
        }
    });
    return object;
}
-(void)insertToLocal:(FSDraftInfo *)draftInfo{
    if (draftInfo) {
        [self.draftInfos addObject:draftInfo];
    }
    
    NSString *dataPath = [FSDraftFileManager draftDataPath];
    [NSKeyedArchiver archiveRootObject:self.draftInfos toFile:dataPath];
}
-(void)deleteToLocal:(FSDraftInfo *)draftInfo{
    if (draftInfo) {
        [self.draftInfos removeObject:draftInfo];
    }
    NSString *dataPath = [FSDraftFileManager draftDataPath];
    [NSKeyedArchiver archiveRootObject:self.draftInfos toFile:dataPath];
}
-(void)updateToLocal:(FSDraftInfo *)draftInfo{
    
}
-(NSArray *)allInfosInLocal{
    [self.draftInfos removeAllObjects];
    NSString *dataPath = [FSDraftFileManager draftDataPath];
    NSArray *drafts = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
    [self.draftInfos addObjectsFromArray:drafts];
    return self.draftInfos;
}
@end
