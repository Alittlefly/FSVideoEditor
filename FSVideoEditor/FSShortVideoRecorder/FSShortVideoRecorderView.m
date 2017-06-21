//
//  FSShortVideoRecorderView.m
//  7nujoom
//
//  Created by 王明 on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSShortVideoRecorderView.h"
#import "FSShortVideoRecorderManager.h"

@interface FSShortVideoRecorderView()

@property (nonatomic, strong) UIButton *flashButton;  //闪光灯
@property (nonatomic, strong) UIButton *finishButton;  //完成按钮
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *recoverCamera;  //切换摄像头

@property (nonatomic, strong) UIButton *cutMusicButton;  //剪音乐
@property (nonatomic, strong) UIButton *beatyButton;  //美颜开关
@property (nonatomic, strong) UIButton *filterButton; //滤镜开关

@property (nonatomic, strong) UIButton *countdownButton;//倒计时开关

@property (nonatomic, strong) NvsLiveWindow *recorderView;
@property (nonatomic, strong) FSShortVideoRecorderManager *recorderManager;

@property (nonatomic, assign) BOOL isFlashOpened;


@end

@implementation FSShortVideoRecorderView {
    BOOL IsArabic;

}

- (void)dealloc {
//    _context = nil;
//    [NvsStreamingContext destroyInstance];
}



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _isFlashOpened = NO;
        
        _recorderManager = [FSShortVideoRecorderManager sharedInstance];
        _recorderView = [_recorderManager getLiveWindow];
        _recorderView.frame= CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:_recorderView];
        
        [self initBaseToolView];
    }
    return self;
}

- (void)initBaseToolView {
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = IsArabic ? CGRectMake(self.frame.size.width - 44 - 15, 20, 44, 44) : CGRectMake(15, 20, 44, 44);
    [_backButton setTitle:@"back" forState:UIControlStateNormal];
    [_backButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backButton];
    
    _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishButton.frame = IsArabic ? CGRectMake(15, 20, 40, 40) : CGRectMake(self.frame.size.width - 15 -40, 20, 40, 40);
    [_finishButton setTitle:@"finish" forState:UIControlStateNormal];
    [_finishButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [_finishButton addTarget:self action:@selector(finishClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_finishButton];
    
    _recoverCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    _recoverCamera.frame = IsArabic ? CGRectMake(CGRectGetMaxX(_finishButton.frame)+30, 20, 40, 40) : CGRectMake(CGRectGetMinX(_finishButton.frame) - 30 -40, 20, 40, 40);
    [_recoverCamera setTitle:@"camera" forState:UIControlStateNormal];
    [_recoverCamera setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [_recoverCamera addTarget:self action:@selector(recoverCameraClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_recoverCamera];
    
    _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _flashButton.frame = IsArabic ? CGRectMake(CGRectGetMaxX(_recoverCamera.frame)+30, 20, 40, 40) : CGRectMake(CGRectGetMinX(_recoverCamera.frame) - 30 -40, 20, 40, 40);
    [_flashButton setTitle:@"flash" forState:UIControlStateNormal];
    [_flashButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [_flashButton addTarget:self action:@selector(flashClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_flashButton];

    _cutMusicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cutMusicButton.frame = IsArabic ? CGRectMake(CGRectGetMaxX(_recoverCamera.frame)+30, 20, 40, 40) : CGRectMake(CGRectGetWidth(self.frame) - 15 -40, CGRectGetMaxY(_finishButton.frame)+30, 40, 40);
    [_cutMusicButton setTitle:@"cutMusic" forState:UIControlStateNormal];
    [_cutMusicButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [_cutMusicButton addTarget:self action:@selector(cutMusicClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cutMusicButton];
}


- (void)backClik {
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderViewQuitRecorderView)]) {
        [self.delegate FSShortVideoRecorderViewQuitRecorderView];
    }
}

- (void)finishClik {

}

- (void)recoverCameraClik {
    BOOL isSuccess = [_recorderManager switchCamera];
}

- (void)flashClik {
    _isFlashOpened = !_isFlashOpened;
    [_recorderManager switchFlash:_isFlashOpened];
}

- (void)cutMusicClik {

}


@end
