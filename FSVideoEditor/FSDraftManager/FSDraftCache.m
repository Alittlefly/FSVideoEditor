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
            object = [[FSDraftCache alloc] init];
        }
    });
    return object;
}
-(void)insertToLocal:(FSDraftInfo *)draftInfo{
    BOOL contain = [self.draftInfos containsObject:draftInfo];
    if (!contain) {
        [self.draftInfos addObject:draftInfo];
        NSString *dataPath = [FSDraftFileManager draftDataPathKey:self.cacheKey];
        [NSKeyedArchiver archiveRootObject:self.draftInfos toFile:dataPath];
    }
}
-(void)deleteToLocal:(FSDraftInfo *)draftInfo{
    
    if (draftInfo) {
        [FSDraftFileManager deleteFile:draftInfo.vFinalPath];
        [FSDraftFileManager deleteFile:draftInfo.vConvertPath];
        [FSDraftFileManager deleteFile:draftInfo.vFirstFramePath];
        [FSDraftFileManager deleteFile:draftInfo.vOriginalPath];
        
        for (NSString *filePath in draftInfo.recordVideoPathArray) {
            [FSDraftFileManager deleteFile:filePath];
        }
        if ([self.draftInfos containsObject:draftInfo]) {
            [self.draftInfos removeObject:draftInfo];
            
            NSString *dataPath = [FSDraftFileManager draftDataPathKey:self.cacheKey];
            [NSKeyedArchiver archiveRootObject:self.draftInfos toFile:dataPath];
        }
    }

}
-(void)deleteAllLocal{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *dataPath = [FSDraftFileManager draftDataPathKey:self.cacheKey];
    [self.draftInfos removeAllObjects];
    if ([defaultManager fileExistsAtPath:dataPath]) {
        [defaultManager removeItemAtPath:dataPath error:nil];
    }
}
-(void)updateToLocal:(FSDraftInfo *)draftInfo{
    
}
-(void)clearMermoryLocal{
    [self.draftInfos removeAllObjects];
}
-(NSArray *)allInfosInLocal{
    if ([self.draftInfos count]) {
        return self.draftInfos;
    }
    
    NSString *dataPath = [FSDraftFileManager draftDataPathKey:self.cacheKey];
    NSArray *drafts = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
    [self.draftInfos addObjectsFromArray:drafts];
    return self.draftInfos;
}
@end
