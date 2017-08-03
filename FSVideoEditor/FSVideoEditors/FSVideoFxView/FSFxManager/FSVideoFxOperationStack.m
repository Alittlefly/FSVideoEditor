//
//  FSVideoFxOperationStacK.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoFxOperationStack.h"
@interface FSVideoFxOperationStack()
@property(nonatomic,strong)NSMutableArray *operationQueue;
@end

@implementation FSVideoFxOperationStack

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        self.operationQueue = [aDecoder decodeObjectForKey:@"operationQueue"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.operationQueue forKey:@"operationQueue"];
}

-(FSVirtualTimeLine *)topVirtualTimeLine{
    if (![self.operationQueue count]) {
        return nil;
    }
    
    return [self.operationQueue lastObject];
}
-(void)pushObject:(FSVirtualTimeLine *)virtualTimeLine{
    if (virtualTimeLine != nil) {
        [self.operationQueue addObject:virtualTimeLine];
    }
}
-(FSVirtualTimeLine *)popVirtualTimeLine{
    FSVirtualTimeLine *topOperation = nil;
    if ([self.operationQueue count]) {
        topOperation = [self.operationQueue lastObject];
        [self.operationQueue removeLastObject];
    }
    return topOperation;
}

-(void)popAll{
    [self.operationQueue removeAllObjects];
}
-(NSArray *)allVirtualTimeLine{
    NSArray *all = [NSArray arrayWithArray:self.operationQueue];
    return all;
}

-(void)pushVideoFxWithFxManager:(FSVideoFxOperationStack *)manager{
    [self.operationQueue addObjectsFromArray:[manager allVirtualTimeLine]];
}
-(NSMutableArray *)operationQueue{
    if (!_operationQueue) {
        _operationQueue = [NSMutableArray array];
    }
    return _operationQueue;
}
@end
