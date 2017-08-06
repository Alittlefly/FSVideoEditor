//
//  FSMusicController.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/29.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimeline.h"
#import "NvsAudioClip.h"
#import "NvsAudioTrack.h"
#import "FSMusicCell.h"
#import "FSCancleController.h"

@protocol FSMusicControllerDelegate <NSObject>


@optional
-(void)musicControllerSelectMusic:(NSString *)musicPath musicId:(NSInteger)musicId;

-(void)musicControllerSelectMusic:(FSMusic *)music;

-(UIViewController *)musicControllerWouldShowMusicDetail:(FSMusic *)music;

@end

@interface FSMusicController : FSCancleController

@property(nonatomic,assign)id<FSMusicControllerDelegate>delegate;

@property(nonatomic,assign)NvsTimeline *timeLine;
@property(nonatomic,assign)BOOL pushed;

- (void)stopPlayCurrentMusic;
@end
