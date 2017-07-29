//
//  FSMusicCollectSever.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSMusic.h"

@protocol FSMusicCollectSeverDelegate <NSObject>
@optional
-(void)musicCollectSeverCollectMusicSuccess:(FSMusic *)music;
-(void)musicCollectSeverCollectFaild:(FSMusic *)music;

-(void)musicSeverGetCollectedMusics:(NSArray<FSMusic *> *)musics;
-(void)musicSeverGetCollectedFaild;

@end

@interface FSMusicCollectSever : NSObject
@property(nonatomic,assign)id<FSMusicCollectSeverDelegate>delegate;
-(void)collectMusic:(FSMusic *)music collect:(BOOL)collect;
-(void)getLikedMusicsList:(NSInteger)fromPage;
@end
