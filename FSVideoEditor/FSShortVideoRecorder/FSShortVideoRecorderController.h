//
//  FSShortVideoRecorderController.h
//  7nujoom
//
//  Created by 王明 on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSShortLanguage.h"

@class FSDraftInfo;
@class FSMusic;

@protocol FSShortVideoRecorderControllerDelegate <NSObject>

@optional
-(UIViewController *)FSShortVideoShowMusicDetailWithMusic:(FSMusic *)music;

@end

@interface FSShortVideoRecorderController : UIViewController

@property (nonatomic, weak) id<FSShortVideoRecorderControllerDelegate> delegate;

@property (nonatomic, assign) BOOL isPresented;

@property (nonatomic, strong) FSDraftInfo *draftInfo;

- (void)showNoviceGuideView:(UIView *)guideView;

@end
