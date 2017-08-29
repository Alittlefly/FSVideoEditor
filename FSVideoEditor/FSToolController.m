//
//  FSToolController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/3.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSToolController.h"
#import "FSShortVideoRecorderController.h"
#import "FSLocalVideoController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FSMusicController.h"
#import "AFNetworking.h"
#import "FSPresentAnimator.h"
#import "FSMusicPlayer.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"

@interface FSToolController ()<FSMusicControllerDelegate>
{
    UIButton *_currentButton;
}
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)FSMusicController *musicView;
@property(nonatomic,strong)FSLocalVideoController *localView;

@end

@implementation FSToolController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 20,CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [_contentView setBackgroundColor:[UIColor whiteColor]];
    [_contentView.layer setCornerRadius:5.0];
    [_contentView.layer setMasksToBounds:YES];
    [self.view addSubview:_contentView];
    
    
    UIButton *videoRecorderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    videoRecorderButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 5 : CGRectGetWidth(_contentView.frame) - 105, 17, 100, 21);
    if ([FSPublishSingleton sharedInstance].isAutoReverse) {
        [videoRecorderButton setTitle:[NSString stringWithFormat:@"< %@",[FSShortLanguage CustomLocalizedStringFromTable:@"Record"]] forState:UIControlStateNormal];
    }
    else {
        [videoRecorderButton setTitle:[NSString stringWithFormat:@"%@ >",[FSShortLanguage CustomLocalizedStringFromTable:@"Record"]] forState:UIControlStateNormal];
    }
    [videoRecorderButton setTitleColor:FSHexRGB(0x73747B) forState:(UIControlStateNormal)];
    [videoRecorderButton setTitleColor:FSHexRGB(0x010A12) forState:(UIControlStateSelected)];
    [videoRecorderButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [videoRecorderButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    videoRecorderButton.tag = 1;
    [_contentView addSubview:videoRecorderButton];
    
    
    UIButton *selectMusic = [UIButton buttonWithType:UIButtonTypeCustom];
    selectMusic.frame = CGRectMake((CGRectGetWidth(_contentView.frame) - 60)/2.0, 17, 60, 21);
    [selectMusic setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"ChooseMusic"] forState:UIControlStateNormal];
    [selectMusic addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    selectMusic.tag = 2;
    [selectMusic setTitleColor:FSHexRGB(0x73747B) forState:(UIControlStateNormal)];
    [selectMusic setTitleColor:FSHexRGB(0x010A12) forState:(UIControlStateSelected)];
    [selectMusic.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [selectMusic setSelected:YES];
     _currentButton = selectMusic;
    [_contentView addSubview:selectMusic];
    
    
    UIButton *videoListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    videoListButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? _contentView.frame.size.width-80 : 20, 17, 60, 21);
    [videoListButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadVideo"] forState:UIControlStateNormal];
    [videoListButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [videoListButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
     videoListButton.tag = 3;
    [videoListButton setTitleColor:FSHexRGB(0x73747B) forState:(UIControlStateNormal)];
    [videoListButton setTitleColor:FSHexRGB(0x010A12) forState:(UIControlStateSelected)];
    [_contentView addSubview:videoListButton];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 54, CGRectGetWidth(_contentView.frame), 1.0)];
    [line setBackgroundColor:FSHexRGB(0xe5e5e5)];
    [_contentView addSubview:line];
    
    
    if (!_musicView) {
        
        FSMusicController *music = [[FSMusicController alloc] init];
        [music setDelegate:self];
        [self addChildViewController:music];
        [music.view setFrame:CGRectMake(0, 55, CGRectGetWidth(self.view.bounds), CGRectGetHeight(_contentView.frame)  - 55 - 20)];
        [_contentView addSubview:music.view];
         _musicView = music;
        
    }

    [self.view setBackgroundColor:[UIColor clearColor]];
    
}

- (void)videoRecorder {
    
    [self stopPlayer];
    
    FSShortVideoRecorderController *svc = [[FSShortVideoRecorderController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)clickButton:(UIButton *)button{
    
    if (button.tag == 1) {
        [self videoRecorder];
    }else{
        [_currentButton setSelected:NO];
         _currentButton = button;
        [_currentButton setSelected:YES];
        
        if (button.tag == 2) {
            
        }else if (button.tag == 3){
            if (!_localView) {
                 _localView = [[FSLocalVideoController alloc] init];
                [_localView.view setFrame:_musicView.view.frame];
                [_contentView addSubview:_localView.view];
                [self addChildViewController:_localView];
            }
            [self stopPlayer];
        }
    
        
        [_localView.view setHidden:button.tag != 3];
        [_musicView.view setHidden:button.tag != 2];
    }
}

- (void)videoList {
    
    [self stopPlayer];
    
    FSLocalVideoController *svc = [[FSLocalVideoController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}
-(void)stopPlayer{
    [_musicView stopPlayCurrentMusic];
    [[FSMusicPlayer sharedPlayer] stop];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
    
    if (_currentButton.tag == 3) {
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNSNotificationVideoEditToolWillShow object:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

#pragma mark -
-(UIViewController *)musicControllerWouldShowMusicDetail:(FSMusic *)music{
    UIViewController *deatilController = nil;
    
    if ([self.delegate respondsToSelector:@selector(musicDetailControllerWithMusic:)]) {
        deatilController = [self.delegate musicDetailControllerWithMusic:music];
    }
    
    NSAssert(![deatilController isKindOfClass:[UINavigationController class]], @"返回的控制器不能为nav");
    return deatilController;
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNSNotificationVideoEditToolWillShow object:nil];

    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

@end
