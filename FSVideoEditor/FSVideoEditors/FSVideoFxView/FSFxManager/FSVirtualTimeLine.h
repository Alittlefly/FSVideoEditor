//
//  FSVirtualTimeLine.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSVideoFx.h"

@interface FSVirtualTimeLine : NSObject<NSCoding>

@property(nonatomic,assign)int64_t duration;
@property(nonatomic,strong)NSMutableArray *videoFxs;

-(void)addVideoFx:(FSVideoFx *)videoFx;
-(void)addVideoFxsInArray:(NSArray *)fxs;
-(NSArray *)allVideoFxs;
@end
