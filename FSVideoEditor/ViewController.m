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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *videoRecorderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    videoRecorderButton.frame = CGRectMake(100, 100, 60, 30);
    videoRecorderButton.backgroundColor = [UIColor redColor];
    [videoRecorderButton setTitle:@"录制" forState:UIControlStateNormal];
    [videoRecorderButton addTarget:self action:@selector(videoRecorder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoRecorderButton];
    
    
    
    UIButton *videoListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    videoListButton.frame = CGRectMake(250, 100, 60, 30);
    videoListButton.backgroundColor = [UIColor redColor];
    [videoListButton setTitle:@"视频" forState:UIControlStateNormal];
    [videoListButton addTarget:self action:@selector(videoList) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoListButton];
}

- (void)videoRecorder {
    FSShortVideoRecorderController *svc = [[FSShortVideoRecorderController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)videoList {
    FSLocalVideoController *svc = [[FSLocalVideoController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
