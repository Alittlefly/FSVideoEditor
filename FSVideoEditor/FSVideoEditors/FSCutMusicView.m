//
//  FSCutMusicView.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/29.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSCutMusicView.h"
#import "FSMusicPlayer.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"

@interface FSCutMusicView()<UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *totalTimeImageView;
@property (nonatomic, strong) UIImageView *currentImageView;
@property (nonatomic, strong) UIImageView *maskView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) NSTimeInterval newTime;

@property (nonatomic, assign) CGFloat totalTime;
@property (nonatomic, assign) CGFloat playTime;

@end

@implementation FSCutMusicView

- (instancetype)initWithFrame:(CGRect)frame audioClip:(NvsAudioClip *)audioClip{
    if (self = [super initWithFrame:frame]) {
        _playTime = 0;
        _totalTime = 0;
        [self createBaseUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame filePath:(NSString *)filePath startTime:(NSTimeInterval)startTime volume:(CGFloat)volume {
    if (self = [super initWithFrame:frame]) {
        _filePath = filePath;
        _playTime = 0;
        _totalTime = 0;
        _newTime = startTime;
        [[FSMusicPlayer sharedPlayer] setFilePath:filePath];
        [[FSMusicPlayer sharedPlayer] playAtTime:startTime];
        if (volume >= 0) {
            [[FSMusicPlayer sharedPlayer] changeVolume:volume];
        }
        else {
            [[FSMusicPlayer sharedPlayer] changeVolume:0.5];
        }
        [self createBaseUI];
        [[FSMusicPlayer sharedPlayer] play];
    }
    return self;
}

- (void)createBaseUI {
    if (_filePath) {
        _totalTime = [[FSMusicPlayer sharedPlayer] soundTotalTime];
    }
    CGFloat totalWidth = self.frame.size.width*_totalTime/15;

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-110, self.frame.size.width, 110)];
    _scrollView.directionalLockEnabled = YES;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsHorizontalScrollIndicator = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(totalWidth, _scrollView.frame.size.height);
    [self addSubview:_scrollView];
    _scrollView.contentOffset = CGPointMake(_newTime*totalWidth/_totalTime, 0);
    
    _totalTimeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, totalWidth, _scrollView.frame.size.height)];
    _totalTimeImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"audio-gray"]];//FSHexRGB(0xA2A4A1);
    [_scrollView addSubview:_totalTimeImageView];
    
    _currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, totalWidth, _scrollView.frame.size.height)];
    _currentImageView.backgroundColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"audio-yellow"]];;//FSHexRGB(0xFACE15);
    [_scrollView addSubview:_currentImageView];
    
    _maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _newTime*totalWidth/_totalTime, _scrollView.frame.size.height)];
    _maskView.translatesAutoresizingMaskIntoConstraints = NO;
    _maskView.backgroundColor = [UIColor blueColor];
    
    _currentImageView.maskView = _maskView;
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? self.frame.size.width-20-100 : 20, CGRectGetMinY(_scrollView.frame)-5-25, 100, 25)];
    _timeLabel.backgroundColor = FSHexRGBAlpha(0x000F1E, 0.5);
    _timeLabel.textColor = FSHexRGB(0xF5F5F5);
    _timeLabel.font = [UIFont systemFontOfSize:11];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    NSString *timeString = [FSShortLanguage CustomLocalizedStringFromTable:@"MusicStartTime"];//NSLocalizedString(@"MusicStartTime", nil);
    _timeLabel.text = [timeString stringByReplacingOccurrencesOfString:@"(0)" withString:[self getCurrentTimeString:_newTime]];
    [_timeLabel sizeToFit];
    _timeLabel.frame = CGRectMake(20, CGRectGetMinY(_scrollView.frame)-5-25, _timeLabel.frame.size.width+20, 25);
    _timeLabel.layer.cornerRadius = 5;
    _timeLabel.layer.masksToBounds = YES;
    [self addSubview:_timeLabel];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMinY(_timeLabel.frame)-5-30, 100, 30)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = FSHexRGB(0xF5F5F5);
    _titleLabel.font = [UIFont systemFontOfSize:13];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"EditMusicTip"];//NSLocalizedString(@"EditMusicTip", nil);
    _titleLabel.shadowColor = [UIColor blackColor];
    //阴影偏移  x，y为正表示向右下偏移
    _titleLabel.shadowOffset = CGSizeMake(1, 1);
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake((self.frame.size.width-_titleLabel.frame.size.width)/2, CGRectGetMinY(_timeLabel.frame)-5-30, _titleLabel.frame.size.width, 30);
    [self addSubview:_titleLabel];
    
    _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 20 : self.frame.size.width- 20-54, CGRectGetMinY(_titleLabel.frame), 54, 30);
    _finishButton.backgroundColor = [UIColor clearColor];
    [_finishButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
    [_finishButton addTarget:self action:@selector(finishCutMusic) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_finishButton];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateMaskViewFrame) userInfo:nil repeats:YES];
//    [_timer setFireDate:[NSDate date]];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)finishCutMusic {
    if ([_timer isValid]) {
        [_timer setFireDate:[NSDate distantFuture]];
        _timer = nil;
    }
    if (_filePath) {
        if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
            [[FSMusicPlayer sharedPlayer] stop];
        }
        if ([self.delegate respondsToSelector:@selector(FSCutMusicViewFinishCutMusicWithTime:)]) {
            [self.delegate FSCutMusicViewFinishCutMusicWithTime:_newTime];
        }
    }
    
}

- (void)updateMaskViewFrame {
    CGRect frame = self.maskView.frame;

    if (_playTime >= 15.0) {
        _playTime = 0;
        frame.size.width = _scrollView.contentOffset.x;
        if (_filePath) {
            NSLog(@"updateMaskViewFrame   FSMusicPlayer %f",_newTime);

            [[FSMusicPlayer sharedPlayer] stop];
            [[FSMusicPlayer sharedPlayer] playAtTime:_newTime];
            [[FSMusicPlayer sharedPlayer] play];
        }
    }
    else {
        _playTime += 0.1;
        frame.size.width += 0.1*self.frame.size.width/15;
    }
    
    self.maskView.frame = frame;
    
    

    
//    if (frame.size.width > self.frame.size.width && frame.size.width <= self.scrollView.contentSize.width) {
//        self.scrollView.contentOffset = CGPointMake(frame.size.width-self.frame.size.width, 0);
//    }
//    else if (frame.size.width > self.scrollView.contentSize.width){
//        [_timer setFireDate:[NSDate distantFuture]];
//    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   // NSLog(@" scrollViewDidScroll contentOffSet %f",scrollView.contentOffset.x);
    if (scrollView.contentOffset.x+self.frame.size.width <= self.maskView.frame.size.width) {
        CGRect frame = self.maskView.frame;
        frame.size.width -= self.frame.size.width/2;
        self.maskView.frame =frame;
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndDecelerating: %f",scrollView.contentOffset.x);
    [self resetMusicStartTime:scrollView];


}

- (NSString *)getCurrentTimeString:(NSTimeInterval)time {
    int min = floor(time/60);
    int sec = ((int)time)%60;
    
    return [NSString stringWithFormat:@"%.2d:%.2d",min,sec];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"scrollViewDidEndDragging: %f",scrollView.contentOffset.x);

    [self resetMusicStartTime:scrollView];
   }

- (void)resetMusicStartTime:(UIScrollView *)scrollView {
    if ([_timer isValid]) {
        [_timer setFireDate:[NSDate distantFuture]];
    }
    _playTime = 0;
    
    CGRect frame = self.maskView.frame;
    frame.size.width = scrollView.contentOffset.x;
    self.maskView.frame =frame;
    
    int time = ceilf(scrollView.contentOffset.x*_totalTime/scrollView.contentSize.width) ;
    //    int min = floor(time/60);
    //    int sec = time%60;
    //    NSLog(@"min:%d     sec:%d",min,sec);
    NSString *timeString = [FSShortLanguage CustomLocalizedStringFromTable:@"MusicStartTime"];//NSLocalizedString(@"MusicStartTime", nil);
    self.timeLabel.text = [timeString stringByReplacingOccurrencesOfString:@"(0)" withString:[self getCurrentTimeString:time]];
    
    _newTime = time;
    
    [_timer setFireDate:[NSDate date]];
    
    if (_filePath) {
        NSLog(@"scrollViewDidEndDecelerating   FSMusicPlayer %f",_newTime);
        [[FSMusicPlayer sharedPlayer] stop];
        [[FSMusicPlayer sharedPlayer] playAtTime:time];
        [[FSMusicPlayer sharedPlayer] play];
    }
}

@end
