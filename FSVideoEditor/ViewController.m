//
//  ViewController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "ViewController.h"
#import "FSShortVideoRecorderController.h"
#import "FSLocalVideoController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FSMusicController.h"
#import "AFNetworking.h"
#import "FSMusicPlayer.h"


@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *videoRecorderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    videoRecorderButton.frame = CGRectMake(0, 0, 60, 30);
    videoRecorderButton.backgroundColor = [UIColor redColor];
    [videoRecorderButton setTitle:@"录制" forState:UIControlStateNormal];
    [videoRecorderButton addTarget:self action:@selector(videoRecorder) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:videoRecorderButton];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIButton *videoListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    videoListButton.frame = CGRectMake(250, 100, 60, 30);
    videoListButton.backgroundColor = [UIColor redColor];
    [videoListButton setTitle:@"视频" forState:UIControlStateNormal];
    [videoListButton addTarget:self action:@selector(videoList) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:videoListButton];
    self.navigationItem.rightBarButtonItem = right;

    
    FSMusicController *music = [[FSMusicController alloc] init];
    [self addChildViewController:music];
    [music.view setFrame:self.view.bounds];
    [self.view addSubview:music.view];
}

- (void)videoRecorder {
    
    [self stopPlayer];

    FSShortVideoRecorderController *svc = [[FSShortVideoRecorderController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)videoList {
    
    [self stopPlayer];
    
    FSLocalVideoController *svc = [[FSLocalVideoController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}
-(void)stopPlayer{
    [[FSMusicPlayer sharedPlayer] stop];
}

- (void)musicList{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
