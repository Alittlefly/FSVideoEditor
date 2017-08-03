//
//  FSDraftWriter.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftWriter.h"
#import "FSDraftCache.h"
@interface FSDraftWriter()
@property(nonatomic,assign)id<FSDraftCacheProtocol> localOperator;
@end

@implementation FSDraftWriter
-(instancetype)init{
    if (self = [super init]) {
        _localOperator = [FSDraftCache sharedDraftCache];
    }
    return self;
}
-(void)deleteLocalDraftInfo:(FSDraftInfo *)draftInfo{
    [_localOperator deleteToLocal:draftInfo];
}
-(void)updateLocalDraftInfo:(FSDraftInfo *)draftInfo{
    [_localOperator updateToLocal:draftInfo];
}
-(void)insertLocalDraftInfo:(FSDraftInfo *)draftInfo{
    [_localOperator insertToLocal:draftInfo];
}
@end
