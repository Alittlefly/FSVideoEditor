//
//  FSDraftCache.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftCache.h"

@implementation FSDraftCache
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
    
}
-(void)deleteToLocal:(FSDraftInfo *)draftInfo{

}
-(void)updateToLocal:(FSDraftInfo *)draftInfo{

}
-(NSArray *)allInfosInLocal{
    return @[];
}
@end
