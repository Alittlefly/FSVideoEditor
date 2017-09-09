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
-(void)musicControllerSelectMusic:(NSString *)musicPath music:(FSMusic *)music;

-(void)musicControllerSelectMusic:(FSMusic *)music;

-(UIViewController *)musicControllerWouldShowMusicDetail:(FSMusic *)music;

- (void)musicControllerHideen;

@end

@interface FSMusicController : FSCancleController

@property(nonatomic,assign)id<FSMusicControllerDelegate>delegate;
@property(nonatomic,assign)BOOL needSelfHeader;

@property(nonatomic,assign)NvsTimeline *timeLine;
@property(nonatomic,assign)BOOL pushed;

- (void)stopPlayCurrentMusic;


- (void)searchMusic;
- (void)clickHotMusic;
- (void)clickCollectMusic;

- (void)clickHotDetail;
- (void)clickHotUseMusic;
- (void)clickHotCollect;
- (void)clickHotPlay;

- (void)clickFaveDeatil;
- (void)clickFaveUseMusic;
- (void)clickFaveCollect;
- (void)clickFavePlay;

@end
