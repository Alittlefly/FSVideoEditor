//
//  FSMusicSever.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSMusic.h"
@protocol FSMusicSeverDelegate <NSObject>

@optional
-(void)musicSeverGetMusics:(NSArray<FSMusic *> *)musics musicTypes:(NSArray<FSMusicType *> *)musicTypes;

-(void)musicSeverGetMusics:(NSArray<FSMusic *> *)musics;

-(void)musicSeverGetFaild;


@end

@interface FSMusicSever : NSObject

@property(nonatomic,assign)id<FSMusicSeverDelegate>delegate;

-(void)getMusicList;

-(void)getMusicListWithType:(NSInteger)type;

@end
