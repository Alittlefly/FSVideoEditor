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
#import "FSTimeCountsdownView.h"
#import "FSSegmentView.h"
#import "FSMoveButton.h"
#import "FSCutMusicView.h"
#import "NvsAudioTrack.h"
#import "FSMusicPlayer.h"
#import "FSAlertView.h"
#import "FSEditorLoading.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"
#import "FSDraftManager.h"

@interface FSShortVideoRecorderView()<FSShortVideoRecorderManagerDelegate, FSFilterViewDelegate, FSTimeCountdownViewDelegate,UIAlertViewDelegate, FSSegmentViewDelegate, FSMoveButtonDelegate, FSCutMusicViewDelegate>

@property (nonatomic, strong) UIButton *flashButton;  //闪光灯
@property (nonatomic, strong) UIButton *finishButton;  //完成按钮
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *recoverCamera;  //切换摄像头
@property (nonatomic, strong) UIButton *cutMusicButton;  //剪音乐
@property (nonatomic, strong) UIButton *beautyButton;  //美颜开关
@property (nonatomic, strong) UIButton *filterButton; //滤镜开关
@property (nonatomic, strong) UIButton *countdownButton;//倒计时开关

@property (nonatomic, strong) FSTimeCountsdownView *timeCountdownView;

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

@property (nonatomic, strong) FSEditorLoading *loading;

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

@property (nonatomic, strong) FSCutMusicView *cutMusicView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGFloat currentVideoTime;

@property (nonatomic, strong) CAGradientLayer *gradientlayer;


@end

@implementation FSShortVideoRecorderView

-(FSEditorLoading *)loading{
    if (!_loading) {
        _loading = [[FSEditorLoading alloc] initWithFrame:self.bounds];
    }
    return _loading;
}

- (void)dealloc {
//    _context = nil;
//    [NvsStreamingContext destroyInstance];
}

- (void)setMusicFilePath:(NSString *)musicFilePath {
    _musicFilePath = musicFilePath;
    if (_currentVideoTime > 0) {
        self.cutMusicButton.enabled = NO;
    }
    else {
        self.cutMusicButton.enabled = YES;
    }
}

-(CAGradientLayer *)gradientlayer
{
    if (!_gradientlayer) {
        _gradientlayer = [CAGradientLayer layer];
        _gradientlayer.colors = @[(__bridge id)FSHexRGBAlpha(0x000000, 0.3).CGColor,
                                  
                                  (__bridge id)FSHexRGBAlpha(0x000000, 0.0).CGColor];
        
        _gradientlayer.locations = @[@(0.0),@(1)];
        [_gradientlayer setStartPoint:CGPointMake(0, 0)];
        [_gradientlayer setEndPoint:CGPointMake(0, 1)];
    }
    
    
    return _gradientlayer;
}

- (instancetype)initWithFrame:(CGRect)frame draftInfo:(FSDraftInfo *)draftInfo {
    if (self = [super initWithFrame:frame]) {
        _draftInfo = draftInfo;
        _isFlashOpened = NO;
        _isBeautyOpened = draftInfo.vBeautyOn;
        _playSpeed = FSShortVideoPlaySpeed_Normal;
        _isRecording = NO;
        _linesArray = [NSMutableArray arrayWithCapacity:0];
        _isAutoRecorder = NO;
        _currentVideoTime = 0.0;
        if (draftInfo.vMusic) {
            _musicFilePath = _draftInfo.vMusic.mPath;
        }

        for (NSNumber *time in _draftInfo.recordVideoTimeArray) {
            _currentVideoTime += [time floatValue];
        }
        
        [self initCameraView];
    }
    return self;
}

- (void)initCameraView {
    
    _recorderManager = [FSShortVideoRecorderManager sharedInstance];
    _recorderManager.delegate = self;
    _recorderView = [_recorderManager getLiveWindow];
    [_recorderManager initBaseData:_draftInfo];
    
    _recorderView.frame= CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:_recorderView];
    //[_recorderManager resumeCapturePreview];
    
    self.gradientlayer.frame = CGRectMake(0, 0, self.frame.size.width, 110);
    [_recorderView.layer addSublayer:self.gradientlayer];
    
    
    [_recorderManager switchBeauty:_isBeautyOpened];
    
    _supportAutoExposure = [_recorderManager isSupportAutoExposure];
    _supportAutoFocus = [_recorderManager isSupportAutoFocus];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocus:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];
    
    if (self.draftInfo.vFilterid) {
        [self changeFilter:self.draftInfo.vFilterid];
    }
    
    [self initBaseToolView];
}

- (void)initBaseToolView {
    _progressView = [[FSProgressView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 5)];
    _progressView.backgroundColor = FSHexRGBAlpha(0x000B17, 0.7);
    _progressView.progressViewColor = FSHexRGB(0xFACE15);
//    _progressView = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 5)];
//    _progressView.thumbTintColor = [UIColor clearColor];
//    _progressView.minimumTrackTintColor = [UIColor yellowColor];
//    _progressView.maximumTrackTintColor = [UIColor clearColor];
//    _progressView.value = 0;
    [self addSubview:_progressView];
    CGFloat totalTime = 0;
    for (NSNumber *time in _draftInfo.recordVideoTimeArray) {
        totalTime += time.floatValue;
        [_progressView setProgress:totalTime/15.0 animated:NO];
        [_progressView stopAnimationWithCuttingLine];
    }
    
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(self.frame.size.width - 20 - 15, 30, 20,20) : CGRectMake(15, 30, 20, 20);
    [_backButton setImage:[UIImage imageNamed:@"recorder-back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backButton];
    
    if ([FSPublishSingleton sharedInstance].isAutoReverse) {
        _backButton.transform = CGAffineTransformMakeScale(-1, 1);
    }
    
    _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishButton.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(15, 20, 40, 40) : CGRectMake(self.frame.size.width - 15 -40, 20, 40, 40);
    if (totalTime > 0) {
        _finishButton.enabled = YES;

    }
    else {
        _finishButton.enabled = NO;
    }
    [_finishButton setImage:[UIImage imageNamed:@"recorder-finish-gray"] forState:UIControlStateNormal];
    [_finishButton addTarget:self action:@selector(finishClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_finishButton];
    
    _recoverCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    _recoverCamera.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(CGRectGetMaxX(_finishButton.frame)+30, 20, 40, 40) : CGRectMake(CGRectGetMinX(_finishButton.frame) - 30 -40, 20, 40, 40);
    [_recoverCamera setImage:[UIImage imageNamed:@"recorder-camera"] forState:UIControlStateNormal];
    [_recoverCamera addTarget:self action:@selector(recoverCameraClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_recoverCamera];
    
    _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _flashButton.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(CGRectGetMaxX(_recoverCamera.frame)+30, 20, 40, 40) : CGRectMake(CGRectGetMinX(_recoverCamera.frame) - 30 -40, 20, 40, 40);
    [_flashButton setImage:[UIImage imageNamed:@"recorder-flash-off"] forState:UIControlStateNormal];
    [_flashButton addTarget:self action:@selector(flashClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_flashButton];
    if (_draftInfo.isFrontCamera) {
        _flashButton.hidden = YES;
    }
    else {
        _flashButton.hidden = NO;
    }

    _cutMusicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cutMusicButton.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(15, CGRectGetMaxY(_finishButton.frame)+30, 40, 40) : CGRectMake(CGRectGetWidth(self.frame) - 15 -40, CGRectGetMaxY(_finishButton.frame)+30, 40, 40);
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
    //_cutMusicLabel.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(CGRectGetMinX(_cutMusicButton.frame), CGRectGetMaxY(_cutMusicButton.frame), CGRectGetWidth(_cutMusicButton.frame), 10) : CGRectMake(CGRectGetMaxX(_cutMusicButton.frame) - CGRectGetWidth(_cutMusicButton.frame), CGRectGetMaxY(_cutMusicButton.frame), CGRectGetWidth(_cutMusicButton.frame), 10);
    _cutMusicLabel.font = [UIFont systemFontOfSize:10];
    _cutMusicLabel.textColor = [UIColor whiteColor];
    _cutMusicLabel.backgroundColor = [UIColor clearColor];
    _cutMusicLabel.textAlignment = NSTextAlignmentCenter;
    _cutMusicLabel.shadowColor = [UIColor blackColor];
    _cutMusicLabel.shadowOffset = CGSizeMake(1, 1);
    _cutMusicLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"CutMusic"];//NSLocalizedString(@"CutMusic", nil);
    [_cutMusicLabel sizeToFit];
    _cutMusicLabel.center = CGPointMake(_cutMusicButton.center.x, CGRectGetMaxY(_cutMusicButton.frame)+_cutMusicLabel.frame.size.height/2);
    [self addSubview:_cutMusicLabel];
    
    _beautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _beautyButton.frame = CGRectMake(CGRectGetMinX(_cutMusicButton.frame), CGRectGetMaxY(_cutMusicLabel.frame)+20, 40, 40);
    [_beautyButton addTarget:self action:@selector(beautyClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_beautyButton];
    
    _beautyLabel = [[UILabel alloc] init];
    //_beautyLabel.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(CGRectGetMinX(_beautyButton.frame), CGRectGetMaxY(_beautyButton.frame), CGRectGetWidth(_beautyButton.frame), 10) : CGRectMake(CGRectGetMaxX(_beautyButton.frame) - CGRectGetWidth(_beautyButton.frame), CGRectGetMaxY(_beautyButton.frame), CGRectGetWidth(_beautyButton.frame), 10);
    _beautyLabel.backgroundColor = [UIColor clearColor];
    _beautyLabel.font = [UIFont systemFontOfSize:10];
    _beautyLabel.textColor = [UIColor whiteColor];
    _beautyLabel.shadowColor = [UIColor blackColor];
    _beautyLabel.shadowOffset = CGSizeMake(1, 1);
    _beautyLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_beautyLabel];
    
    if (_draftInfo.vBeautyOn) {
        [_beautyButton setImage:[UIImage imageNamed:@"recorder-beauty-on"] forState:UIControlStateNormal];
        _beautyLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"BeautifyOn"];//NSLocalizedString(@"BeautifyOn", nil);

    }
    else {
        [_beautyButton setImage:[UIImage imageNamed:@"recorder-beauty-off"] forState:UIControlStateNormal];
        _beautyLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"BeautifyOff"];//NSLocalizedString(@"BeautifyOn", nil);

    }
    [_beautyLabel sizeToFit];
    _beautyLabel.center = CGPointMake(_beautyButton.center.x, CGRectGetMaxY(_beautyButton.frame)+_beautyLabel.frame.size.height/2);
    
    _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _filterButton.frame = CGRectMake(CGRectGetMinX(_beautyButton.frame), CGRectGetMaxY(_beautyLabel.frame)+20, 40, 40);
    [_filterButton setImage:[UIImage imageNamed:@"recorder-filter"] forState:UIControlStateNormal];
    [_filterButton addTarget:self action:@selector(filterClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_filterButton];
    
    _filterLabel = [[UILabel alloc] init];
    //_filterLabel.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(CGRectGetMinX(_filterButton.frame), CGRectGetMaxY(_filterButton.frame), CGRectGetWidth(_filterButton.frame), 15) : CGRectMake(CGRectGetMaxX(_filterButton.frame) - CGRectGetWidth(_filterButton.frame), CGRectGetMaxY(_filterButton.frame), CGRectGetWidth(_filterButton.frame), 15);
    _filterLabel.backgroundColor = [UIColor clearColor];
    _filterLabel.font = [UIFont systemFontOfSize:10];
    _filterLabel.textColor = [UIColor whiteColor];
    _filterLabel.shadowColor = [UIColor blackColor];
    _filterLabel.shadowOffset = CGSizeMake(1, 1);
    _filterLabel.textAlignment = NSTextAlignmentCenter;
    _filterLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"ColorFilter"];
    [_filterLabel sizeToFit];
    _filterLabel.center = CGPointMake(_filterButton.center.x, CGRectGetMaxY(_filterButton.frame)+_filterLabel.frame.size.height/2);
    [self addSubview:_filterLabel];
    
    _countdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _countdownButton.frame = CGRectMake(CGRectGetMinX(_filterButton.frame), CGRectGetMaxY(_filterLabel.frame)+20, 40, 40);
    [_countdownButton setImage:[UIImage imageNamed:@"recorder-watch"] forState:UIControlStateNormal];
    [_countdownButton addTarget:self action:@selector(countdownClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_countdownButton];
    
    _countdownLabel = [[UILabel alloc] init];
   // _countdownLabel.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(CGRectGetMinX(_countdownButton.frame), CGRectGetMaxY(_countdownButton.frame), CGRectGetWidth(_countdownButton.frame), 10) : CGRectMake(CGRectGetMaxX(_countdownButton.frame) - CGRectGetWidth(_countdownButton.frame), CGRectGetMaxY(_countdownButton.frame), CGRectGetWidth(_countdownButton.frame), 10);
    _countdownLabel.backgroundColor = [UIColor clearColor];
    _countdownLabel.font = [UIFont systemFontOfSize:10];
    _countdownLabel.textColor = [UIColor whiteColor];
    _countdownLabel.shadowColor = [UIColor blackColor];
    _countdownLabel.shadowOffset = CGSizeMake(1, 1);
    _countdownLabel.textAlignment = NSTextAlignmentCenter;
    _countdownLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"Countdown"];//NSLocalizedString(@"Countdown", nil);
    [_countdownLabel sizeToFit];
    _countdownLabel.center = CGPointMake(_countdownButton.center.x, CGRectGetMaxY(_countdownButton.frame)+_countdownLabel.frame.size.height/2);
    [self addSubview:_countdownLabel];
    
    _imageAutoFocusRect = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    _imageAutoFocusRect.backgroundColor = [UIColor clearColor];
    _imageAutoFocusRect.image = [UIImage imageNamed:@"recorder-focus"];
//    _imageAutoFocusRect.layer.borderColor = [UIColor redColor].CGColor;
//    _imageAutoFocusRect.layer.borderWidth = 1;
//    _imageAutoFocusRect.layer.masksToBounds = YES;
    [self addSubview:_imageAutoFocusRect];
    _imageAutoFocusRect.hidden = YES;
    
    _recorderButton = [[FSMoveButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame)-90)/2, CGRectGetHeight(self.frame)-25-90, 90, 90)];
    _recorderButton.backgroundColor = [UIColor clearColor];
    [_recorderButton setImage:[UIImage imageNamed:@"recorder-start"] forState:UIControlStateNormal];
//    [_recorderButton addTarget:self action:@selector(pauseRecorder) forControlEvents:UIControlEventTouchUpInside];
//    [_recorderButton addTarget:self action:@selector(startRecorder) forControlEvents:UIControlEventTouchDown];
    _recorderButton.delegate = self;
    
    [self addSubview:_recorderButton];

    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(CGRectGetMinX(_recorderButton.frame)-50-40, 0, 40, 40) : CGRectMake(CGRectGetMaxX(_recorderButton.frame)+50, 0, 40, 40);
    _deleteButton.center = CGPointMake(_deleteButton.center.x, _recorderButton.center.y);
    [_deleteButton setImage:[UIImage imageNamed:@"recorder-delete"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteVideo) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deleteButton];
    if (_draftInfo.recordVideoPathArray.count > 0) {
        _deleteButton.hidden = NO;
    }
    else {
        _deleteButton.hidden = YES;
    }
    
    _faceUButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _faceUButton.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(CGRectGetMaxX(_recorderButton.frame)+50, 0, 40, 40) : CGRectMake(CGRectGetMinX(_recorderButton.frame)-50-40, 0, 40, 40);
    _faceUButton.center = CGPointMake(_faceUButton.center.x, _recorderButton.center.y);
    [_faceUButton setImage:[UIImage imageNamed:@"recorder-faceu"] forState:UIControlStateNormal];
    [_faceUButton addTarget:self action:@selector(faceuClick) forControlEvents:UIControlEventTouchUpInside];
    _faceUButton.hidden = YES;
    [self addSubview:_faceUButton];
    
    _segmentView = [[FSSegmentView alloc] initWithItems:@[[FSShortLanguage CustomLocalizedStringFromTable:@"VerySlow"],[FSShortLanguage CustomLocalizedStringFromTable:@"Slow"],[FSShortLanguage CustomLocalizedStringFromTable:@"Normal"],[FSShortLanguage CustomLocalizedStringFromTable:@"Fast"],[FSShortLanguage CustomLocalizedStringFromTable:@"VeryFast"]]];
    _segmentView.frame = CGRectMake(30, CGRectGetMinY(_recorderButton.frame)-15-40, CGRectGetWidth(self.frame)-60, 40);
    _segmentView.selectedColor = FSHexRGB(0xFACE15);//[UIColor yellowColor];
    _segmentView.backgroundColor = FSHexRGBAlpha(0x001428, 0.6);[UIColor lightGrayColor];
    _segmentView.selectedTextColor = FSHexRGB(0x1A1D20);//[UIColor redColor];
    _segmentView.unSelectedTextColor = FSHexRGB(0xF5F5F5);
    _segmentView.selectedSegmentIndex = 2;
    _segmentView.layer.cornerRadius = 5;
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
    if (_deleteButton.hidden == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[FSShortLanguage CustomLocalizedStringFromTable:@"CancelEditing"] delegate:self cancelButtonTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Cancel"] otherButtonTitles:[FSShortLanguage CustomLocalizedStringFromTable:@"Confirm"], nil];
        alert.tag = 1001;
        [alert show];
    }
    else {
        [self quit];
    }
    
}

- (void)quit {
    [_recorderManager quitRecording];
    if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
        [[FSMusicPlayer sharedPlayer] stop];
    }
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderViewQuitRecorderView)]) {
        [self.delegate FSShortVideoRecorderViewQuitRecorderView];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1001) {
        if (buttonIndex == 1) {
            [self quit];
        }
    }
    else if (alertView.tag == 1002) {
        if (buttonIndex == 1) {
            [_recorderManager deleteVideoFile];
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
    
    [self addSubview:self.loading];
    [self.loading loadingViewShow];
    
    _draftInfo.recordVideoTimeArray = _recorderManager.timeArray;
    _draftInfo.recordVideoPathArray = _recorderManager.filePathArray;
    _draftInfo.recordVideoSpeedArray = _recorderManager.speedArray;
    
    if (_isRecording) {
        [self pauseRecorder];
    }
    [_recorderManager finishRecorder];
}

- (void)recoverCameraClik {
    BOOL isSuccess = [_recorderManager switchCamera];
    if (isSuccess) {
        _draftInfo.isFrontCamera = !_draftInfo.isFrontCamera;
    }
    
    if (_draftInfo.isFrontCamera) {
        _flashButton.hidden = YES;
    }
    else {
        _flashButton.hidden = NO;
    }
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
        _cutMusicView = [[FSCutMusicView alloc] initWithFrame:self.bounds filePath:_draftInfo.vMusic.mPath startTime:_musicStartTime];
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
    _draftInfo.vBeautyOn = _isBeautyOpened;
    if (_isBeautyOpened) {
        [_beautyButton setImage:[UIImage imageNamed:@"recorder-beauty-on"] forState:UIControlStateNormal];
        [_beautyLabel setText:[FSShortLanguage CustomLocalizedStringFromTable:@"BeautifyOn"]];
        [self showAlertView:[FSShortLanguage CustomLocalizedStringFromTable:@"BeautifyOnTip"]];
    }
    else {
        [_beautyButton setImage:[UIImage imageNamed:@"recorder-beauty-off"] forState:UIControlStateNormal];
        [_beautyLabel setText:[FSShortLanguage CustomLocalizedStringFromTable:@"BeautifyOff"]];
        [self showAlertView:[FSShortLanguage CustomLocalizedStringFromTable:@"BeautifyOffTip"]];
    }
    [_beautyLabel sizeToFit];
    _beautyLabel.center = CGPointMake(_beautyButton.center.x, CGRectGetMaxY(_beautyButton.frame)+_beautyLabel.frame.size.height/2);
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
    
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderViewShowFilterView)]) {
        [self.delegate FSShortVideoRecorderViewShowFilterView];
    }
}

- (void)finishChangeFilter {
    _backButton.hidden= NO;
    _recoverCamera.hidden = NO;
    _finishButton.hidden = NO;
    if (_draftInfo.isFrontCamera) {
        _flashButton.hidden = YES;
    }
    else {
        _flashButton.hidden = NO;
    }
    _cutMusicButton.hidden = NO;
    _beautyButton.hidden = NO;
    _filterButton.hidden = NO;
    _countdownButton.hidden = NO;
    _cutMusicLabel.hidden = NO;
    _filterLabel.hidden = NO;
    _beautyLabel.hidden = NO;
    _countdownLabel.hidden = NO;
    _recorderButton.hidden = NO;
    _faceUButton.hidden = YES;
    if (_currentVideoTime == 0) {
        _deleteButton.hidden = YES;
    }
    else {
        _deleteButton.hidden = NO;
    }
    _segmentView.hidden = NO;
    _isOpenFilterView = NO;
    
    if ([_draftInfo.vFilterid isEqualToString:[FSShortLanguage CustomLocalizedStringFromTable:@"NoFilter"]]) {
        _filterLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"ColorFilter"];
    }
    else {
        _filterLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:_draftInfo.vFilterid];
    }
}

- (void)FSFilterViewChooseFilter:(NSString *)filter {
    
}

- (void)changeFilter:(NSString *)filterName {
    _draftInfo.vFilterid = filterName;
    [_recorderManager addFilter:filterName];
    if ([filterName isEqualToString:@"NoFilter"] && _draftInfo.vBeautyOn) {
        [_recorderManager switchBeauty:YES];
    }
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
        self.timeCountdownView =[[FSTimeCountsdownView alloc] initWithFrame:CGRectMake((self.frame.size.width-91)/2, (self.frame.size.height-174)/2, 91, 174) timeNumber:3 number:15];
        self.timeCountdownView.delegate = self;

    }
    self.timeCountdownView.backgroundColor =[UIColor clearColor];
    [self addSubview:self.timeCountdownView];
    
}

- (void)startRecorder {
    if (_currentVideoTime >= 15) {
        [self showAlertView:[FSShortLanguage CustomLocalizedStringFromTable:@"VideoTimeMaxTip"]];
        return;
    }

    [[FSMusicPlayer sharedPlayer] setFilePath:_draftInfo.vMusic.mPath];

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
    
    if (_musicFilePath != nil && _musicFilePath.length > 0) {
        [[FSMusicPlayer sharedPlayer] setRate:self.recorderManager.recorderSpeed];
        //if (_currentVideoTime==0) {
            [[FSMusicPlayer sharedPlayer] playAtTime:_musicStartTime+_currentVideoTime];
        //}
        [[FSMusicPlayer sharedPlayer] play];
    }
    
    if (!_isAutoRecorder) {
        [self.recorderButton setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
        self.recorderButton.layer.cornerRadius = self.recorderButton.frame.size.width/2;
        self.recorderButton.layer.masksToBounds =YES;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.recorderButton.transform =  CGAffineTransformMakeScale(1.5,1.5);
            
            [self.recorderButton.layer addAnimation:[self alphaLight:0.5 fromValue:50.0f toValue:10.0f] forKey:@"aAlpha1"];
            self.recorderButton.layer.borderColor = FSHexRGB(0x0BC2C6).CGColor;
  
        } completion:^(BOOL finished) {
        
            [self.recorderButton.layer removeAnimationForKey:@"aAlpha1"];
            
            [self.recorderButton.layer addAnimation:[self alphaLight:0.7 fromValue:5.0f toValue:10.0f] forKey:@"aAlpha2"];
            self.recorderButton.layer.borderColor = FSHexRGB(0x0BC2C6).CGColor;

        }];

    }
    else {
        [self.recorderButton setImage:[UIImage imageNamed:@"recorder-auto"] forState:UIControlStateNormal];
    }
    
    [self.recorderManager startRecording:nil];

}

#pragma mark - 空心圆动画
-(CABasicAnimation *)alphaLight:(float)time fromValue:(float)from toValue:(float)to
{
    CABasicAnimation *animation =[CABasicAnimation animationWithKeyPath:@"borderWidth"];
    animation.fromValue = [NSNumber numberWithFloat:from];
    animation.toValue = [NSNumber numberWithFloat:to];
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return animation;
}

- (void)pauseRecorder {
    _isRecording = NO;
    
    _backButton.hidden= NO;
    _recoverCamera.hidden = NO;
    if (_draftInfo.isFrontCamera) {
        _flashButton.hidden = YES;
    }
    else {
        _flashButton.hidden = NO;
    }
    _cutMusicButton.hidden = NO;
    _beautyButton.hidden = NO;
    _filterButton.hidden = NO;
    _countdownButton.hidden = NO;
    _cutMusicLabel.hidden = NO;
    _filterLabel.hidden = NO;
    _beautyLabel.hidden = NO;
    _countdownLabel.hidden = NO;
    _faceUButton.hidden = YES;
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
            
        [self.recorderButton.layer removeAnimationForKey:@"aAlpha2"];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.recorderButton.transform =  CGAffineTransformMakeScale(1.0,1.0);
            
            [self.recorderButton.layer addAnimation:[self alphaLight:0.3 fromValue:10.0f toValue:50.0f] forKey:@"aAlpha3"];
            self.recorderButton.layer.borderColor = FSHexRGB(0x0BC2C6).CGColor;
            
        } completion:^(BOOL finished) {
            
            [self.recorderButton.layer removeAnimationForKey:@"aAlpha3"];
            [self.recorderButton setImage:[UIImage imageNamed:@"recorder-start"] forState:UIControlStateNormal];
            
        }];
    }
    else {
        _isAutoRecorder = NO;
        [self.recorderButton setImage:[UIImage imageNamed:@"recorder-start"] forState:UIControlStateNormal];
    }
}

- (void)showAlertView:(NSString *)message {
    FSAlertView *alet = [[FSAlertView alloc] init];
    [alet showWithMessage:message];
}


#pragma mark - FSMoveButtonDelegate
- (void)FSMoveButtonCancelTrackingWithEvent:(UIEvent *)event {
    //self.recorderButton.transform = CGAffineTransformIdentity;
    [self pauseRecorder];
    [UIView animateWithDuration:0.3 animations:^{
        self.recorderButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height-25-90/2);
    }];

}

- (void)FSMoveButtonEndTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self pauseRecorder];

    [UIView animateWithDuration:0.3 animations:^{
        self.recorderButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height-25-90/2);
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
    [self startRecorder];

    CGPoint tpoint = [touch locationInView:self];
    
    if (CGRectContainsPoint(_recorderButton.frame, tpoint)) {
       // self.recorderButton.transform = CGAffineTransformTranslate(self.recorderButton.transform, tpoint.x, tpoint.y);
        self.recorderButton.center = tpoint;

    }
}

- (void)deleteVideo {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[FSShortLanguage CustomLocalizedStringFromTable:@"DeleteVideoTip"] delegate:self cancelButtonTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Cancel"] otherButtonTitles:[FSShortLanguage CustomLocalizedStringFromTable:@"Confirm"], nil];
    alert.tag = 1002;
    [alert show];
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
    if (_draftInfo.isFrontCamera) {
        _flashButton.hidden = YES;
    }
    else {
        _flashButton.hidden = NO;
    }
    _cutMusicButton.hidden = NO;
    _beautyButton.hidden = NO;
    _filterButton.hidden = NO;
    _countdownButton.hidden = NO;
    _cutMusicLabel.hidden = NO;
    _filterLabel.hidden = NO;
    _beautyLabel.hidden = NO;
    _countdownLabel.hidden = NO;
    _recorderButton.hidden = NO;
    _faceUButton.hidden = YES;
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
    if (_draftInfo.isFrontCamera) {
        _flashButton.hidden = YES;
    }
    else {
        _flashButton.hidden = NO;
    }
    _cutMusicButton.hidden = NO;
    _beautyButton.hidden = NO;
    _filterButton.hidden = NO;
    _countdownButton.hidden = NO;
    _cutMusicLabel.hidden = NO;
    _filterLabel.hidden = NO;
    _beautyLabel.hidden = NO;
    _countdownLabel.hidden = NO;
    _recorderButton.hidden = NO;
    _faceUButton.hidden = YES;
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
    _currentVideoTime = time;
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
    _currentVideoTime = videoTime;
    
    [self.progressView setProgress:videoTime/15.0 animated:NO];
    [self.progressView deleteCuttingLine];
    
    self.countdownButton.enabled = YES;
    self.recorderButton.enabled = YES;


    if (videoTime < 5.0) {
        _finishButton.enabled = NO;
        [_finishButton setImage:[UIImage imageNamed:@"recorder-finish-gray"] forState:UIControlStateNormal];
    }
    
    if (videoTime <= 0.0) {
        _deleteButton.hidden = YES;
        if (_musicFilePath != nil && _musicFilePath.length > 0) {
            _cutMusicButton.enabled = YES;
        }
    }
}

- (void)FSShortVideoRecorderManagerPauseRecorder {
    [self.progressView stopAnimationWithCuttingLine];
}

- (void)FSShortVideoRecorderManagerFailedRecorder {
    [self.loading loadingViewhide];

}

- (void)FSShortVideoRecorderManagerConvertorFaild {
    [self.loading loadingViewhide];

}

- (void)FSShortVideoRecorderManagerFinishedRecorder:(NSString *)normalFilePath convertFilePath:(NSString *)convertFilePath {
    [self.loading loadingViewhide];
    
    if ([self.delegate respondsToSelector:@selector(FSShortVideoRecorderViewFinishRecorder:convertFilePath:speed:musicStartTime:)]) {
        [self.delegate FSShortVideoRecorderViewFinishRecorder:normalFilePath convertFilePath:convertFilePath speed:self.recorderManager.recorderSpeed musicStartTime:_musicStartTime] ;
    }
}
@end
