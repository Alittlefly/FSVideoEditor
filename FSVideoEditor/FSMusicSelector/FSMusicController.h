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

@interface FSMusicController : UIViewController
@property(nonatomic,assign)NvsTimeline *timeLine;
@end
