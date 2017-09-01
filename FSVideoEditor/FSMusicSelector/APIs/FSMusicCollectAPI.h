//
//  FSMusicCollectAPI.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSMusic.h"
@protocol FSMusicCollectAPIDelegate <NSObject>

@optional
-(void)collectMusicSuccess:(NSString *)taskId;
-(void)collectMusicFaild:(NSString *)taskId;
@end

@interface FSMusicCollectAPI : NSObject
@property(nonatomic,strong)NSString *taskId;
@property(nonatomic,copy)FSMusic *music;

@property(nonatomic,assign)id<FSMusicCollectAPIDelegate>delegate;
-(void)collectMusic:(NSInteger)musicId collect:(BOOL)collect;
@end
