//
//  FSDraftReader.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftReader.h"
#import "FSDraftCache.h"

@interface FSDraftReader ()
@property(nonatomic,assign)id<FSDraftCacheProtocol> localOperator;
@end

@implementation FSDraftReader
-(instancetype)init{
    if (self = [super init]) {
        _localOperator = [FSDraftCache sharedDraftCache];
    }
    return self;
}

-(NSArray<FSDraftInfo *> *)allDraftInfoInLocal{
    return [_localOperator allInfosInLocal];
}
-(void)clearMemoryDrafts{
    [_localOperator clearMermoryLocal];
}
@end
