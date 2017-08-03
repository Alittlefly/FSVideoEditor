//
//  FSVideoFxOperationStacK.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSVirtualTimeLine.h"

@interface FSVideoFxOperationStack : NSObject<NSCoding,NSCopying>
-(FSVirtualTimeLine *)topVirtualTimeLine;
-(void)pushObject:(FSVirtualTimeLine *)virtualTimeLine;
-(FSVirtualTimeLine *)popVirtualTimeLine;

-(void)popAll;
-(NSArray *)allVirtualTimeLine;

-(void)pushVideoFxWithFxManager:(FSVideoFxOperationStack *)manager;
@end
