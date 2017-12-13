//
//  FSMusicToolController.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/12/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSMusic.h"
#import "FSMusicController.h"

@protocol FSMusicToolControllerDelegate <NSObject>

@optional
-(UIViewController *)FSMusicToolVCDidShowMusicDetailWithMusic:(FSMusic *)music;
- (void)FSMusicToolVCDidSelectedMusic:(FSMusic *)music filePath:(NSString *)filePath;

@end

@interface FSMusicToolController : UIViewController

@property (nonatomic, weak) id<FSMusicToolControllerDelegate> delegate;
@property(nonatomic,strong)FSMusicController *musicView;

- (void)clickChooseMaterialPageCancelStatistics;

@end
