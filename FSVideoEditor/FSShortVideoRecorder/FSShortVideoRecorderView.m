//
//  FSShortVideoRecorderView.m
//  7nujoom
//
//  Created by 王明 on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSShortVideoRecorderView.h"
#import "FSShortVideoRecorderManager.h"
#import "FSProgressView.h"
#import "FSFilterView.h"
#import "FSTimeCountdownView.h"
#import "FSSegmentView.h"
#import "FSMoveButton.h"
#import "FSCutMusicView.h"
#import "NvsAudioTrack.h"
#import "FSMusicPlayer.h"

BOOL IsArabic;

@interface FSShortVideoRecorderView()<FSShortVideoRecorderManagerDelegate, FSFilterViewDelegate, FSTimeCountdownViewDelegate,UIAlertViewDelegate, FSSegmentViewDelegate, FSMoveButtonDelegate, FSCutMusicViewDelegate>

@property (nonatomic, strong) UIButton *flashButton;  //闪光灯
@property (nonatomic, strong) UIButton *finishButton;  //完成按钮
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *recoverCamera;  //切换摄像头
@property (nonatomic, strong) UIButton *cutMusicButton;  //剪音乐
@property (nonatomic, strong) UIButton *beautyButton;  //美颜开关
@property (nonatomic, strong) UIButton *filterButton; //滤镜开关
@property (nonatomic, strong) UIButton *countdownButton;//倒计时开关

@property (nonatomic, strong) FSTimeCountdownView *timeCountdownView;

@property (nonatomic, strong) UILabel *cutMusicLabel;
@property (nonatomic, strong) UILabel *beautyLabel;
@property (nonatomic, strong) UILabel *filterLabel;
@property (nonatomic, strong) UILabel *countdownLabel;

@property (nonatomic, strong) FSProgressView *progressView;
//@property (nonatomic, strong) UISlider *progressView;

@property (nonatomic, strong) UIImageView *imageAutoFocusRect; //对焦视图

@property (nonatomic, strong) FSMoveButton *recorderButton;
@property (nonatomic, strong) UIButton *faceUButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) FSSegmentView *segmentView;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) NvsLiveWindow *recorderView;
@property (nonatomic, strong) FSShortVideoRecorderManager *recorderManager;

@property (nonatomic, assign) BOOL isFlashOpened;
@property (nonatomic, assign) BOOL isBeautyOpened;
@property (nonatomic, assign) BOOL supportAutoFocus;
@property (nonatomic, assign) BOOL supportAutoExposure;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isOpenFilterView;
@property (nonatomic, strong) NSMutableArray *linesArray;
@property (nonatomic, assign) BOOL isAutoRecorder;

@property (nonatomic, assign) FSShortVideoPlaySpeed playSpeed;

@property (nonatomic, strong) FSFilterView *filterView;
@property (nonatomic, strong) UILabel *recorderAniLabel;

@property (nonatomic, strong) FSCutMusicView *cutMusicView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;


@end

@implementation FSShortVideoRecorderView

- (void)dealloc {
//    _context = nil;
//    [NvsStreamingContext destroyInstance];
}

- (void)setMusicFilePath:(NSString *)musicFilePath {
    _musicFilePath = musicFilePath;
    self.cutMusicButton.enabled = YES;
    [[FSMusicPlayer sharedPlayer] setFilePath:_musicFilePath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _isFlashOpened = NO;
        _isBeautyOpened = YES;
        _playSpeed = FSShortVideoPlaySpeed_Normal;
        _isRecording = NO;
        _linesArray = [NSMutableArray arrayWithCapacity:0];
        _isAutoRecorder = NO;
        
        _recorderManager = [FSShortVideoRecorderManager sharedInstance];
        _recorderManager.delegate = self;
        _recorderView = [_recorderManager getLiveWindow];
        [_recorderManager initBaseData];
        _recorderView.frame= CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:_recorderView];
        //[_recorderManager resumeCapturePreview];

        
        [_recorderManager switchBeauty:YES];
        
        _supportAutoExposure = [_recorderManager isSupportAutoExposure];
        _supportAutoFocus = [_recorderManager isSupportAutoFocus];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocus:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGestureRecognizer];

        
        [self initBaseToolView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeCapturePreview) name:@"ResumeCapturePreview" object:nil];
    }
    return self;
}

- (void)initBaseToolView {
    _progressView = [[FSProgressView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 5)];
    _progressView.backgroundColor = [UIColor clearColor];
    _progressView.progressViewColor = [UIColor yellowColor];
//    _progressView = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 5)];
//    _progressView.thumbTintColor = [UIColor clearColor];
//    _progressView.minimumTrackTintColor = [UIColor yellowColor];
//    _progressView.maximumTrackTintColor = [UIColor clearColor];
//    _progressView.value = 0;
    [self addSubview:_progressView];
    
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = IsArabic ? CGRectMake(self.frame.size.width - 20 - 15, 20, 20,20) : CGRectMake(15, 20, 20, 20);
    //[_backButton setTitle:@"back" forState:UIControlStateNormal];
    [_backButton setImage:[UIImage imageNamed:@"recorder-back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backButton];
    
    _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishButton.frame = IsArabic ? CGRectMake(15, 20, 40, 40) : CGRectMake(self.frame.size.width - 15 -40, 20, 40, 40);
   // [_finishButton setTitle:@"finish" forState:UIControlStateNormal];
    _finishButton.enabled = NO;
    [_finishButton setImage:[UIImage imageNamed:@"recorder-finish-gray"] forState:UIControlStateNormal];
    [_finishButton addTarget:self action:@selector(finishClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_finishButton];
    
    _recoverCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    _recoverCamera.frame = IsArabic ? CGRectMake(CGRectGetMaxX(_finishButton.frame)+30, 20, 40, 40) : CGRectMake(CGRectGetMinX(_finishButton.frame) - 30 -40, 20, 40, 40);
    //[_recoverCamera setTitle:@"recorder-camera" forState:UIControlStateNormal];
    [_recoverCamera setImage:[UIImage imageNamed:@"recorder-camera"] forState:UIControlStateNormal];
    [_recoverCamera addTarget:self action:@selector(recoverCameraClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_recoverCamera];
    
    _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _flashButton.frame = IsArabic ? CGRectMake(CGRectGetMaxX(_recoverCamera.frame)+30, 20, 40, 40) : CGRectMake(CGRectGetMinX(_recoverCamera.frame) - 30 -40, 20, 40, 40);
   // [_flashButton setTitle:@"flash" forState:UIControlStateNormal];
    [_flashButton setImage:[UIImage imageNamed:@"recorder-flash-off"] forState:UIControlStateNormal];
    [_flashButton addTarget:self action:@selector(flashClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_flashButton];

    _cutMusicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cutMusicButton.frame = IsArabic ? CGRectMake(CGRectGetMaxX(_recoverCamera.frame)+30, 20, 40, 40) : CGRectMake(CGRectGetWidth(self.frame) - 15 -40, CGRectGetMaxY(_finishButton.frame)+30, 40, 40);
    //[_cutMusicButton setTitle:@"cutMusic" forState:UIControlStateNormal];
    [_cutMusicButton setImage:[UIImage imageNamed:@"recorder-cut"] forState:UIControlStateNormal];
    [_cutMusicButton addTarget:self action:@selector(cutMusicClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cutMusicButton];
    
    if (_musicFilePath != nil && _musicFilePath.length > 0) {
        _cutMusicButton.enabled = YES;
    }
    else {
        _cutMusicButton.enabled = NO;
    }
    
    _cutMusicLabel = [[UILabel alloc] init];
    _cutMusicLabel.frame = IsArabic ? CGRectMake(CGRectGetMinX(_cutMusicButton.frame), CGRectGetMaxY(_cutMusicButton.frame), CGRectGetWidth(_cutMusicButton.frame), 10) : CGRectMake(CGRectGetMaxX(_cutMusicButton.frame) - CGRectGetWidth(_cutMusicButton.frame), CGRectGetMaxY(_cutMusicButton.frame), CGRectGetWidth(_cutMusicButton.frame), 10);
    _cutMusicLabel.font = [UIFont systemFontOfSize:9];
    _cutMusicLabel.textColor = [UIColor whiteColor];
    _cutMusicLabel.backgroundColor = [UIColor clearColor];
    _cutMusicLabel.textAlignment = NSTextAlignmentCenter;
    _cutMusicLabel.text = @"剪音乐";
    [self addSubview:_cutMusicLabel];
    
    _beautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _beautyButton.frame = CGRectMake(CGRectGetMinX(_cutMusicButton.frame), CGRectGetMaxY(_cutMusicLabel.frame)+20, 40, 40);
    //[_beautyButton setTitle:@"beaty" forState:UIControlStateNormal];
    [_beautyButton setImage:[UIImage imageNamed:@"recorder-beauty-on"] forState:UIControlStateNormal];
    [_beautyButton addTarget:self action:@selector(beautyClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_beautyButton];
    
    _beautyLabel = [[UILabel alloc] init];
    _beautyLabel.frame = IsArabic ? CGRectMake(CGRectGetMinX(_beautyButton.frame), CGRectGetMaxY(_cutMusicButton.frame), CGRectGetWidth(_beautyButton.frame), 10) : CGRectMake(CGRectGetMaxX(_beautyButton.frame) - CGRectGetWidth(_beautyButton.frame), CGRectGetMaxY(_beautyButton.frame), CGRectGetWidth(_beautyButton.frame), 10);
    _beautyLabel.backgroundColor = [UIColor clearColor];
    _beautyLabel.font = [UIFont systemFontOfSize:9];
    _beautyLabel.textColor = [UIColor whiteColor];
    _beautyLabel.textAlignment = NSTextAlignmentCenter;
    _beautyLabel.text = @"美颜开";
    [self addSubview:_beautyLabel];
    
    _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _filterButton.frame = CGRectMake(CGRectGetMinX(_beautyButton.frame), CGRectGetMaxY(_beautyLabel.frame)+20, 40, 40);
    //[_filterButton setTitle:@"filter" forState:UIControlStateNormal];
    [_filterButton setImage:[UIImage imageNamed:@"recorder-filter"] forState:UIControlStateNormal];
    [_filterButton addTarget:self action:@selector(filterClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_filterButton];
    
    _filterLabel = [[UILabel alloc] init];
    _filterLabel.frame = IsArabic ? CGRectMake(CGRectGetMinX(_filterButton.frame), CGRectGetMaxY(_filterButton.frame), CGRectGetWidth(_filterButton.frame), 15) : CGRectMake(CGRectGetMaxX(_filterButton.frame) - CGRectGetWidth(_filterButton.frame), CGRectGetMaxY(_filterButton.frame), CGRectGetWidth(_filterButton.frame), 15);
    _filterLabel.backgroundColor = [UIColor clearColor];
    _filterLabel.font = [UIFont systemFontOfSize:9];
    _filterLabel.textColor = [UIColor whiteColor];
    _filterLabel.textAlignment = NSTextAlignmentCenter;// IsArabic ? NSTextAlignmentLeft : NSTextAlignmentRight;
    _filterLabel.text = @"滤镜";
    [self addSubview:_filterLabel];
    
    _countdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _countdownButton.frame = CGRectMake(CGRectGetMinX(_filterButton.frame), CGRectGetMaxY(_filterLabel.frame)+20, 40, 40);
    //[_countdownButton setTitle:@"countdown" forState:UIControlStateNormal];
    [_countdownButton setImage:[UIImage imageNamed:@"recorder-watch"] forState:UIControlStateNormal];
    [_countdownButton addTarget:self action:@selector(countdownClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_countdownButton];
    
    _countdownLabel = [[UILabel alloc] init];
    _countdownLabel.frame = IsArabic ? CGRectMake(CGRectGetMinX(_countdownButton.frame), CGRectGetMaxY(_countdownButton.frame), CGRectGetWidth(_countdownButton.frame), 10) : CGRectMake(CGRectGetMaxX(_countdownButton.frame) - CGRectGetWidth(_countdownButton.frame), CGRectGetMaxY(_countdownButton.frame), CGRectGetWidth(_countdownButton.frame), 10);
    _countdownLabel.backgroundColor = [UIColor clearColor];
    _countdownLabel.font = [UIFont systemFontOfSize:9];
    _countdownLabel.textColor = [UIColor whiteColor];
    _countdownLabel.textAlignment = NSTextAlignmentCenter;
    _countdownLabel.text = @"倒计时";
    [self addSubview:_countdownLabel];
    
    _imageAutoFocusRect = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    _imageAutoFocusRect.backgroundColor = [UIColor clearColor];
    _imageAutoFocusRect.image = [UIImage imageNamed:@"recorder-focus"];
//    _imageAutoFocusRect.layer.borderColor = [UIColor redColor].CGColor;
//    _imageAutoFocusRect.layer.borderWidth = 1;
//    _imageAutoFocusRect.layer.masksToBounds = YES;
    [self addSubview:_imageAutoFocusRect];
    _imageAutoFocusRect.hidden = YES;
    
    _recorderButton = [FSMoveButton buttonWithType:UIButtonTypeCustom];
    _recorderButton.frame = CGRectMake((CGRectGetWidth(self.frame)-90)/2, CGRectGetHeight(self.frame)-25-90, 90, 90);
    [_recorderButton setImage:[UIImage imageNamed:@"recorder-start"] forState:UIControlStateNormal];
    [_recorderButton addTarget:self action:@selector(pauseRecorder) forControlEvents:UIControlEventTouchUpInside];
    [_recorderButton addTarget:self action:@selector(startRecorder) forControlEvents:UIControlEventTouchDown];
    _recorderButton.delegate = self;
//    [_recorderButton addTarget:self action:@selector(moveRecorderButton:) forControlEvents:UIControlEventTouchDragInside];
//    [_recorderButton addTarget:self action:@selector(moveRecorderButton:) forControlEvents:UIControlEventTouchDragOutside];


    [self addSubview:_recorderButton];
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.frame = IsArabic ? CGRectMake(CGRectGetMinX(_recorderButton.frame)-50-40, 0, 40, 40) : CGRectMake(CGRectGetMaxX(_recorderButton.frame)+50, 0, 40, 40);
    _deleteButton.center = CGPointMake(_deleteButton.center.x, _recorderButton.center.y);
    [_deleteButton setImage:[UIImage imageNamed:@"recorder-delete"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteVideo) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deleteButton];
    
    _faceUButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _faceUButton.frame = IsArabic ? CGRectMake(CGRectGetMaxX(_recorderButton.frame)+50, 0, 40, 40) : CGRectMake(CGRectGetMinX(_recorderButton.frame)-50-40, 0, 40, 40);
    _faceUButton.center = CGPointMake(_faceUButton.center.x, _recorderButton.center.y);
    [_faceUButton setImage:[UIImage imageNamed:@"recorder-faceu"] forState:UIControlStateNormal];
    [_faceUButton addTarget:self action:@selector(faceuClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_faceUButton];
    
    _segmentView = [[FSSegmentView alloc] initWithItems:@[@"极慢",@"慢",@"标准",@"快",@"极快"]];
    _segmentView.frame = CGRectMake(30, CGRectGetMinY(_recorderButton.frame)-15-40, CGRectGetWidth(self.frame)-60, 40);
    _segmentView.selectedColor = FSHexRGB(0xFACE15);//[UIColor yellowColor];
    _segmentView.backgroundColor = FSHexRGBAlpha(0x001428, 0.6);[UIColor lightGrayColor];
    _segmentView.selectedTextColor = FSHexRGB(0x1A1D20);//[UIColor redColor];
    _segmentView.unSelectedTextColor = FSHexRGB(0xF5F5F5);
    _segmentView.selectedSegmentIndex = 2;
    _segmentView.layer.cornerRadius = 20;
    _segmentView.layer.masksToBounds = YES;
    _segmentView.delegate = self;
    [self addSubview:_segmentView];
    
}

-(UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)resumeCapturePreview {
    //_recorderManager.delegate = self;
    [_recorderManager resumeCapturePreview];
    _recorderButton.enabled = YES;
}

- (void)backClik {
//    if () {
//        
//    }
//    else {
//    
//    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定退出录制吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [_recorderManager quitRecording];
        if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
            [[FSMusicPlayer sharedPlayer] stop];
        }
        if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderViewQuitRecorderView)]) {
            [self.delegate FSShortVideoRecorderViewQuitRecorderView];
        }
    }
}

- (void)tapToFocus:(UITapGestureRecognizer *)recognizer {
    if (_isOpenFilterView) {
        return;
    }
    CGPoint point = [recognizer locationInView:self.recorderView];
    CGFloat rectHalfWidth = self.imageAutoFocusRect.frame.size.width/2;
    if (point.x - rectHalfWidth < 0 || point.x + rectHalfWidth > self.recorderView.frame.size.width || point.y - rectHalfWidth < 0 || point.y + rectHalfWidth > self.recorderView.frame.size.height) {
        return;
    }
    
    self.imageAutoFocusRect.center = point;
    self.imageAutoFocusRect.hidden = NO;
    self.imageAutoFocusRect.transform = CGAffineTransformMakeScale(2.5, 2.5);

    [UIView animateWithDuration:0.5 animations:^{
        self.imageAutoFocusRect.transform = CGAffineTransformMakeScale(1.0, 1.0);

    }
     completion:^(BOOL finished) {
         self.imageAutoFocusRect.hidden = YES;
     }];
    if (_supportAutoFocus) {
        [_recorderManager startAutoFocus:self.imageAutoFocusRect.center];
    }
    else {
        [_recorderManager startAutiExposure:self.imageAutoFocusRect.center];
    }
}

- (void)finishClik {
    _recorderButton.enabled = NO;
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.frame = CGRectMake(0, 0, 100, 100);
        _activityView.center = self.center;
        [self addSubview:_activityView];
    }
    [_activityView startAnimating];
    if (_isRecording) {
        [self pauseRecorder];
    }
    [_recorderManager finishRecorder];
}

- (void)recoverCameraClik {
    BOOL isSuccess = [_recorderManager switchCamera];
//    if (isSuccess) {
//        if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderViewFinishRecorder:)]) {
//            [self.delegate FSShortVideoRecorderViewFinishRecorder:[_recorderManager getVideoPath]];
//        }
//    }
}

- (void)flashClik {
    _isFlashOpened = !_isFlashOpened;
    if (_isFlashOpened) {
        [_flashButton setImage:[UIImage imageNamed:@"recorder-flash-on"] forState:UIControlStateNormal];
    }
    else {
        [_flashButton setImage:[UIImage imageNamed:@"recorder-flash-off"] forState:UIControlStateNormal];

    }
    [_recorderManager switchFlash:_isFlashOpened];
}

- (void)cutMusicClik {
    _backButton.hidden= YES;
    _recoverCamera.hidden = YES;
    _finishButton.hidden = YES;
    _flashButton.hidden = YES;
    _cutMusicButton.hidden = YES;
    _beautyButton.hidden = YES;
    _filterButton.hidden = YES;
    _countdownButton.hidden = YES;
    _cutMusicLabel.hidden = YES;
    _filterLabel.hidden = YES;
    _beautyLabel.hidden = YES;
    _countdownLabel.hidden = YES;
    _recorderButton.hidden = YES;
    _faceUButton.hidden = YES;
    _deleteButton.hidden = YES;
    _segmentView.hidden = YES;
    
    _isOpenFilterView = YES;

    if (!_cutMusicView) {
//        _cutMusicView = [[FSCutMusicView alloc] initWithFrame:self.bounds audioClip:audio];
        _cutMusicView = [[FSCutMusicView alloc] initWithFrame:self.bounds filePath:_musicFilePath startTime:_musicStartTime];
        _cutMusicView.delegate = self;
        [self addSubview:_cutMusicView];
        _cutMusicView.hidden = YES;
    }
    _cutMusicView.hidden = NO;
//    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderViewEditMusic)]) {
//        [self.delegate FSShortVideoRecorderViewEditMusic];
//    }
}

- (void)beautyClik {
    _isBeautyOpened = !_isBeautyOpened;
    if (_isBeautyOpened) {
        [_beautyButton setImage:[UIImage imageNamed:@"recorder-beauty-on"] forState:UIControlStateNormal];
    }
    else {
        [_beautyButton setImage:[UIImage imageNamed:@"recorder-beauty-off"] forState:UIControlStateNormal];
    }
    [_recorderManager switchBeauty:_isBeautyOpened];
}

- (void)filterClik {
    _backButton.hidden= YES;
    _recoverCamera.hidden = YES;
    _finishButton.hidden = YES;
    _flashButton.hidden = YES;
    _cutMusicButton.hidden = YES;
    _beautyButton.hidden = YES;
    _filterButton.hidden = YES;
    _countdownButton.hidden = YES;
    _cutMusicLabel.hidden = YES;
    _filterLabel.hidden = YES;
    _beautyLabel.hidden = YES;
    _countdownLabel.hidden = YES;
    _recorderButton.hidden = YES;
    _faceUButton.hidden = YES;
    _deleteButton.hidden = YES;
    _segmentView.hidden = YES;
    
    _isOpenFilterView = YES;
    
    if (!_filterView) {
        _filterView = [[FSFilterView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-120, self.frame.size.width, 120)];
        _filterView.backgroundColor = [UIColor clearColor];
        _filterView.hidden = YES;
        _filterView.delegate =self;
        [self addSubview:_filterView];
    }
    
    _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.frame.size.height, _filterView.frame.size.width, _filterView.frame.size.height);
    _filterView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.frame.size.height-_filterView.frame.size.height, _filterView.frame.size.width, _filterView.frame.size.height);
        
    }];
}

- (void)FSFilterViewFinishedChooseFilter {
    [UIView animateWithDuration:0.5 animations:^{
        _filterView.frame =CGRectMake(_filterView.frame.origin.x, self.frame.size.height, _filterView.frame.size.width, _filterView.frame.size.height);
        
    } completion:^(BOOL finished) {
        _filterView.hidden = YES;
        
        _backButton.hidden= NO;
        _recoverCamera.hidden = NO;
        _finishButton.hidden = NO;
        _flashButton.hidden = NO;
        _cutMusicButton.hidden = NO;
        _beautyButton.hidden = NO;
        _filterButton.hidden = NO;
        _countdownButton.hidden = NO;
        _cutMusicLabel.hidden = NO;
        _filterLabel.hidden = NO;
        _beautyLabel.hidden = NO;
        _countdownLabel.hidden = NO;
        _recorderButton.hidden = NO;
        _faceUButton.hidden = NO;
        _deleteButton.hidden = NO;
        _segmentView.hidden = NO;
        _isOpenFilterView = NO;

    }];
}

- (void)FSFilterViewChooseFilter:(NSString *)filter {
    [_recorderManager addFilter:filter];
    
}


- (void)countdownClik {
    _backButton.hidden= YES;
    _recoverCamera.hidden = YES;
    _flashButton.hidden = YES;
    _cutMusicButton.hidden = YES;
    _beautyButton.hidden = YES;
    _filterButton.hidden = YES;
    _countdownButton.hidden = YES;
    _cutMusicLabel.hidden = YES;
    _filterLabel.hidden = YES;
    _beautyLabel.hidden = YES;
    _countdownLabel.hidden = YES;
    _faceUButton.hidden = YES;
    _deleteButton.hidden = YES;
    _segmentView.hidden = YES;
    
    _finishButton.enabled = NO;
    _recorderButton.enabled = NO;
    
   // _isOpenFilterView = YES;
    //倒计时动画
    //倒计时View
    if (!_timeCountdownView) {
        self.timeCountdownView =[[FSTimeCountdownView alloc] initWithFrame:CGRectMake((self.frame.size.width-50)/2, (self.frame.size.height-50)/2, 50, 50) timeNumber:3 number:15];
        self.timeCountdownView.delegate = self;

    }
    self.timeCountdownView.backgroundColor =[UIColor clearColor];
    [self addSubview:self.timeCountdownView];
    
}

- (void)startRecorder {
    NSLog(@"startRecorder");

    _isRecording = YES;
    
    _backButton.hidden= YES;
    _recoverCamera.hidden = YES;
    _flashButton.hidden = YES;
    _cutMusicButton.hidden = YES;
    _beautyButton.hidden = YES;
    _filterButton.hidden = YES;
    _countdownButton.hidden = YES;
    _cutMusicLabel.hidden = YES;
    _filterLabel.hidden = YES;
    _beautyLabel.hidden = YES;
    _countdownLabel.hidden = YES;
    _faceUButton.hidden = YES;
    _deleteButton.hidden = YES;
    _segmentView.hidden = YES;
    
    _isOpenFilterView = NO;
    
    [self.recorderManager startRecording:nil];
    [self.recorderButton setBackgroundColor:[UIColor clearColor]];
    [self.recorderButton setImage:[UIImage imageNamed:@"recorder-auto"] forState:UIControlStateNormal];
    
    if (_musicFilePath != nil && _musicFilePath.length > 0) {
        [[FSMusicPlayer sharedPlayer] setRate:self.recorderManager.recorderSpeed];
        [[FSMusicPlayer sharedPlayer] playAtTime:_musicStartTime];
        [[FSMusicPlayer sharedPlayer] play];
    }
    
    if (!_isAutoRecorder) {
        [self.recorderButton setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
        [self.recorderButton setBackgroundColor:[UIColor redColor]];
        self.recorderButton.layer.cornerRadius = self.recorderButton.frame.size.width/2;
        self.recorderButton.layer.masksToBounds =YES;
        
//        if (!_panGesture) {
//            _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveRecorderButton:)];
//            [self addGestureRecognizer:_panGesture];
//        }
        
        if (!_recorderAniLabel) {
            _recorderAniLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.recorderButton.frame.size.width-10, self.recorderButton.frame.size.height-10)];
            _recorderAniLabel.backgroundColor = [UIColor blackColor];
            _recorderAniLabel.layer.cornerRadius = _recorderAniLabel.frame.size.width/2;
            _recorderAniLabel.layer.masksToBounds = YES;
            _recorderAniLabel.transform =  CGAffineTransformMakeScale(0.5,0.5);
            _recorderAniLabel.userInteractionEnabled = NO;
            [self.recorderButton addSubview:_recorderAniLabel];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            self.recorderButton.transform =  CGAffineTransformMakeScale(1.2,1.2);
            self.recorderAniLabel.transform =  CGAffineTransformMakeScale(1.0,1.0);
  
        } completion:^(BOOL finished) {
            [self.recorderAniLabel.layer addAnimation:[self alphaLight:0.5 fromValue:1.0 toValue:0.75 repeat:YES] forKey:@"aAlpha"];

        }];

    }

}

- (void)pauseRecorder {
    NSLog(@"pauseRecorder");
    _isRecording = NO;
    
    _backButton.hidden= NO;
    _recoverCamera.hidden = NO;
    _flashButton.hidden = NO;
    _cutMusicButton.hidden = NO;
    _beautyButton.hidden = NO;
    _filterButton.hidden = NO;
    _countdownButton.hidden = NO;
    _cutMusicLabel.hidden = NO;
    _filterLabel.hidden = NO;
    _beautyLabel.hidden = NO;
    _countdownLabel.hidden = NO;
    _faceUButton.hidden = NO;
    _deleteButton.hidden = NO;
    _segmentView.hidden = NO;
    
    _isOpenFilterView = NO;
    
    [self.recorderManager stopRecording];
    // [self.recorderManager resumeCapturePreview];
    
    if (_musicFilePath != nil && _musicFilePath.length > 0) {
        if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
            [[FSMusicPlayer sharedPlayer] pause];
        }
    }
    
    if (!_isAutoRecorder) {
        [self.recorderAniLabel.layer removeAnimationForKey:@"aAlpha"];
        

        [UIView animateWithDuration:0.5 animations:^{
            self.recorderAniLabel.transform =  CGAffineTransformMakeScale(0.2,0.2);
            self.recorderButton.transform =  CGAffineTransformMakeScale(1.0,1.0);
            
        } completion:^(BOOL finished) {

            [self.recorderAniLabel removeFromSuperview];
            self.recorderAniLabel = nil;
            self.recorderButton.layer.cornerRadius = 0;
            

            self.recorderButton.backgroundColor = [UIColor clearColor];
            [self.recorderButton setImage:[UIImage imageNamed:@"recorder-start"] forState:UIControlStateNormal];

        }];
        

    }
    else {
        _isAutoRecorder = NO;
        [self.recorderButton setImage:[UIImage imageNamed:@"recorder-start"] forState:UIControlStateNormal];

    }
}


#pragma mark - FSMoveButtonDelegate
- (void)FSMoveButtonCancelTrackingWithEvent:(UIEvent *)event {
    //self.recorderButton.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.3 animations:^{
        self.recorderButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height-25-self.recorderButton.frame.size.height/2);
    }];

}

- (void)FSMoveButtonEndTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [UIView animateWithDuration:0.3 animations:^{
        self.recorderButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height-25-self.recorderButton.frame.size.height/2);
    }];
}

- (void)FSMoveButtonContinueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint tpoint = [touch locationInView:self];
    
    if (CGRectContainsPoint(_recorderButton.frame, tpoint)) {
        //self.recorderButton.transform = CGAffineTransformTranslate(self.recorderButton.transform, tpoint.x, tpoint.y);
        self.recorderButton.center = tpoint;
    }
}

- (void)FSMoveButtonBeginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint tpoint = [touch locationInView:self];
    
    if (CGRectContainsPoint(_recorderButton.frame, tpoint)) {
       // self.recorderButton.transform = CGAffineTransformTranslate(self.recorderButton.transform, tpoint.x, tpoint.y);
        self.recorderButton.center = tpoint;

    }
}

- (void)moveRecorderButton:(UIPanGestureRecognizer *)gesture {
    
    //获取手势的位置
    CGPoint position =[gesture translationInView:self];
    
    NSLog(@"");
    
    //通过stransform 进行平移交换
    self.recorderButton.transform = CGAffineTransformTranslate(self.recorderButton.transform, position.x, position.y);
    //将增量置为零
    [gesture setTranslation:CGPointZero inView:self];
}

- (CABasicAnimation *)alphaLight:(float)time fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue repeat:(BOOL)repeat {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = [NSNumber numberWithFloat:fromValue];
    animation.toValue = [NSNumber numberWithFloat:toValue];
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = repeat ? MAXFLOAT : 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return animation;
}

- (void)deleteVideo {
    [_recorderManager deleteVideoFile];
}

- (void)faceuClick {

}

- (void)FSSegmentView:(FSSegmentView *)segmentView selected:(NSInteger)index {
    switch (index) {
        case 0:
            _playSpeed = FSShortVideoPlaySpeed_Hyperslow;
            self.recorderManager.recorderSpeed = 3;
            break;
        case 1:
            _playSpeed = FSShortVideoPlaySpeed_Slow;
            self.recorderManager.recorderSpeed = 2;
            break;
        case 2:
            _playSpeed = FSShortVideoPlaySpeed_Normal;
            self.recorderManager.recorderSpeed = 1;
            break;
        case 3:
            _playSpeed = FSShortVideoPlaySpeed_Quick;
            self.recorderManager.recorderSpeed = 0.5;
            break;
        case 4:
            _playSpeed = FSShortVideoPlaySpeed_VeryFast;
            self.recorderManager.recorderSpeed = 1.0/3.0;
            break;
            
        default:
            break;
    }

}

#pragma mark - 
- (void)FSCutMusicViewFinishCutMusic:(NvsAudioClip *)newAudioClip {
    _cutMusicView.hidden = YES;
    [_cutMusicView removeFromSuperview];
    _cutMusicView = nil;
    
    _backButton.hidden= NO;
    _recoverCamera.hidden = NO;
    _finishButton.hidden = NO;
    _flashButton.hidden = NO;
    _cutMusicButton.hidden = NO;
    _beautyButton.hidden = NO;
    _filterButton.hidden = NO;
    _countdownButton.hidden = NO;
    _cutMusicLabel.hidden = NO;
    _filterLabel.hidden = NO;
    _beautyLabel.hidden = NO;
    _countdownLabel.hidden = NO;
    _recorderButton.hidden = NO;
    _faceUButton.hidden = NO;
    _deleteButton.hidden = NO;
    _segmentView.hidden = NO;
    _isOpenFilterView = NO;
}

- (void)FSCutMusicViewFinishCutMusicWithTime:(NSTimeInterval)newStartTime {
    _musicStartTime = newStartTime;
    
    _cutMusicView.hidden = YES;
    [_cutMusicView removeFromSuperview];
    _cutMusicView = nil;
    
    _backButton.hidden= NO;
    _recoverCamera.hidden = NO;
    _finishButton.hidden = NO;
    _flashButton.hidden = NO;
    _cutMusicButton.hidden = NO;
    _beautyButton.hidden = NO;
    _filterButton.hidden = NO;
    _countdownButton.hidden = NO;
    _cutMusicLabel.hidden = NO;
    _filterLabel.hidden = NO;
    _beautyLabel.hidden = NO;
    _countdownLabel.hidden = NO;
    _recorderButton.hidden = NO;
    _faceUButton.hidden = NO;
    _deleteButton.hidden = NO;
    _segmentView.hidden = NO;
    _isOpenFilterView = NO;
}

#pragma mark - FSTimeCountdownViewDelegate
- (void)timeCountViewCountToZero {
    _timeCountdownView.delegate = nil;
    [_timeCountdownView removeFromSuperview];
    _timeCountdownView = nil;
    _isAutoRecorder = YES;
    
    [self startRecorder];
    
    //_finishButton.enabled = YES;
    _recorderButton.enabled = YES;

}

#pragma mark - FSShortVideoRecorderManagerDelegate

- (void)FSShortVideoRecorderManagerProgress:(CGFloat)time {
    CGFloat speed = 1;
    switch (_playSpeed) {
        case FSShortVideoPlaySpeed_Hyperslow:
            speed = 3;
            break;
        case FSShortVideoPlaySpeed_Slow:
            speed = 2;
            break;
        case FSShortVideoPlaySpeed_Normal:
            speed = 1;
            break;
        case FSShortVideoPlaySpeed_Quick:
            speed = 0.75;
            break;
        case FSShortVideoPlaySpeed_VeryFast:
            speed = 0.5;
            break;
        default:
            break;
    }
    
    if (time <= 15) {
        _cutMusicButton.enabled = NO;
        [self.progressView setProgress:time/15.0 animated:YES];
    }
    
    if (time >= 5.0 && time <15) {
        _finishButton.enabled = YES;
        [_finishButton setImage:[UIImage imageNamed:@"recorder-finish-red"] forState:UIControlStateNormal];
    }
    else if (time >= 15) {
        self.countdownButton.enabled = NO;
        self.recorderButton.enabled = NO;
        [self finishClik];
    }
    else if (time < 5.0) {
        _finishButton.enabled = NO;
        [_finishButton setImage:[UIImage imageNamed:@"recorder-finish-gray"] forState:UIControlStateNormal];
    }
}

- (void)FSShortVideoRecorderManagerDeleteVideo:(CGFloat)videoTime {
    NSLog(@"FSShortVideoRecorderManagerDeleteVideo: %f",videoTime);
    
    [self.progressView setProgress:videoTime/15.0 animated:NO];
    [self.progressView deleteCuttingLine];
    
    self.countdownButton.enabled = YES;
    self.recorderButton.enabled = YES;


    if (videoTime < 5.0) {
        _finishButton.enabled = NO;
        [_finishButton setImage:[UIImage imageNamed:@"recorder-finish-gray"] forState:UIControlStateNormal];
    }
    
    if (videoTime <= 0 && _musicFilePath != nil && _musicFilePath.length > 0) {
        _cutMusicButton.enabled = YES;
    }
}

- (void)FSShortVideoRecorderManagerPauseRecorder {
    [self.progressView stopAnimationWithCuttingLine];
}

- (void)FSShortVideoRecorderManagerFinishRecorder:(NSString *)filePath {
    [_activityView stopAnimating];
    
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderViewFinishRecorder:speed:musicStartTime:)]) {
        [self.delegate FSShortVideoRecorderViewFinishRecorder:filePath speed:self.recorderManager.recorderSpeed musicStartTime:_musicStartTime] ;
    }
}

- (void)FSShortVideoRecorderManagerFinish:(NvsTimeline *)timeLine {
    [_activityView stopAnimating];
    
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderViewFinishTimeLine:speed:musicStartTime:)]) {
        [self.delegate FSShortVideoRecorderViewFinishTimeLine:timeLine speed:self.recorderManager.recorderSpeed musicStartTime:_musicStartTime] ;
    }
}

@end
