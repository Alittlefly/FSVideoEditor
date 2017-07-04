//
//  FSNvsFxManager.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/4.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsTimelineVideoFx.h"


@class FSVideoFx;
@interface FSNvsFxManager : NSObject

-(FSVideoFx *)topVideoFx;
-(void)pushVideoFx:(FSVideoFx *)videoFx;
-(FSVideoFx *)popVideoFx;
-(void)popAll;
-(NSArray *)allVideoFx;
-(void)pushVideoFxFromManager:(FSNvsFxManager *)manager;
@end


@interface FSVideoFx : NSObject
@property(nonatomic,strong)NSString *videoFxId;
@property(nonatomic,assign)int64_t startPoint;
@property(nonatomic,assign)int64_t endPoint;
@property(nonatomic,strong)NvsTimelineVideoFx *timeLineFx;
@property(nonatomic,strong)FSVideoFx *reflectVideoFx;
@end
