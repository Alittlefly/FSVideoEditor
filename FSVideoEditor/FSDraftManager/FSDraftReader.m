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
@property(nonatomic,strong)id<FSDraftCacheProtocol> localOperator;
@end

@implementation FSDraftReader
-(NSArray<FSDraftInfo *> *)allDraftInfoInLocal{
    return @[];
}
@end
