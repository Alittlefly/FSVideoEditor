//
//  FSMusicAPI.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSMusicAPIDelegate<NSObject>

-(void)musicApiGetMusics:(id)responesObject;

@end
@interface FSMusicAPI : NSObject

@property(nonatomic,assign)id<FSMusicAPIDelegate>delegate;
-(void)getMusicWithParam:(id)param;
-(void)cancleTask;
@end
