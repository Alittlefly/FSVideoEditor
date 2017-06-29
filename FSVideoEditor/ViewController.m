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
#include "NvcConvertor.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FSMusicController.h"


@interface ViewController ()<NvcConvertorDelegate>

@end

@implementation ViewController
{
    NvcConvertor*  mConvertor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *videoRecorderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    videoRecorderButton.frame = CGRectMake(100, 100, 60, 30);
    videoRecorderButton.backgroundColor = [UIColor redColor];
    [videoRecorderButton setTitle:@"录制" forState:UIControlStateNormal];
    [videoRecorderButton addTarget:self action:@selector(videoRecorder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoRecorderButton];
    
//    UIButton *musicListButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    musicListButton.frame = CGRectMake(170, 100, 60, 30);
//    musicListButton.backgroundColor = [UIColor redColor];
//    [musicListButton setTitle:@"选择音乐" forState:UIControlStateNormal];
//    [musicListButton addTarget:self action:@selector(musicList) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:musicListButton];
    
    UIButton *videoListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    videoListButton.frame = CGRectMake(250, 100, 60, 30);
    videoListButton.backgroundColor = [UIColor redColor];
    [videoListButton setTitle:@"视频" forState:UIControlStateNormal];
    [videoListButton addTarget:self action:@selector(videoList) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoListButton];
    
    UIButton * mStartBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [mStartBtn setFrame:CGRectMake(120, 400, 100, 50)];
    [mStartBtn setTitle:@"开始转码" forState:UIControlStateNormal];
    [mStartBtn addTarget:self action:@selector(beginConvert) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:mStartBtn];
    
    mConvertor=[[NvcConvertor alloc] init];
    mConvertor.delegate = self;
    
    FSMusicController *music = [[FSMusicController alloc] init];
//    [self.navigationController pushViewController:music animated:YES];
    [self addChildViewController:music];
    [music.view setFrame:CGRectMake(0, 200, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 200)];
    [self.view addSubview:music.view];
}

- (void)videoRecorder {
    FSShortVideoRecorderController *svc = [[FSShortVideoRecorderController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)videoList {
    FSLocalVideoController *svc = [[FSLocalVideoController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}
- (void)musicList{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)beginConvert{
//    mConvertorFileName = [NSURL URLWithString:@"file:///var/mobile/Media/DCIM/100APPLE/IMG_0262.mp4"];
//    if(mConvertorFileName == nil)
//        return;
//    
    if([mConvertor IsOpened]){
        
        [mConvertor stop];
        [mConvertor close];
        return;
    }
    
    [self setupConvertor:[NSURL URLWithString:@"file:///var/mobile/Media/DCIM/100APPLE/IMG_0332.mov"]];
    
}

- (void)setupConvertor:(NSURL*)path
{
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * tmpfilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"outtt.mov"];
    
    struct SNvcOutputConfig config;
    config.from = 0;
    config.to = INT_MAX;
    config.dataRate = 0;
    config.scale.num = 1;
    config.scale.den = 1;
    
    int nTmp = config.from;
    config.from = config.to;
    config.to = nTmp;
    
    NSInteger ret = [mConvertor open:path.absoluteString outputFile:tmpfilePath setting:&config];
    if(ret != NVC_NOERROR){
        NSString* error = nil;
        if(ret == NVC_E_INVALID_POINTER)
            error = @"无效指针";
        else if(ret == NVC_E_INVALID_PARAMETER)
            error = @"无效参数";
        else if(ret == NVC_E_NO_VIDEO_STREAM)
            error = @"输入文件不存在视频流";
        else if(ret == NVC_E_CONVERTOR_IS_OPENED)
            error = @"当前转码器已经打开";
        else if(ret == NVC_E_CONVERTOR_IS_STARTED)
            error = @"正在转码";
        
        return;
    }
    
    [mConvertor start];
    
    
}

#pragma mark NVConvertorDelegate
- (void)convertFinished
{
    
    [mConvertor stop];
    [mConvertor close];
    NSString* segmentPath = nil;
    
    
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    segmentPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"out.mov"];
    
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:segmentPath] == NO)
    {
        return;
    }
    
    AVPlayerViewController *player = [[AVPlayerViewController alloc]init];
    NSURL* pathURL = [NSURL fileURLWithPath:segmentPath];
    player.player = [AVPlayer playerWithURL:pathURL];
    
    [self presentViewController:player animated:YES completion:nil];
}

- (void)convertFaild:(NSError *)error
{
}




@end
