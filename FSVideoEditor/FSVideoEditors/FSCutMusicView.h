//
//  FSCutMusicView.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/29.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsAudioClip.h"


@protocol FSCutMusicViewDelegate <NSObject>

- (void)FSCutMusicViewFinishCutMusic:(NvsAudioClip *)newAudioClip;
- (void)FSCutMusicViewFinishCutMusicWithTime:(NSTimeInterval )newStartTime;

@end

@interface FSCutMusicView : UIView

@property (nonatomic, weak) id<FSCutMusicViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame audioClip:(NvsAudioClip *)audioClip;
- (instancetype)initWithFrame:(CGRect)frame filePath:(NSString *)filePath  startTime:(NSTimeInterval)startTime;

@end
