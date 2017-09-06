//
//  FSControlVolumeView.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/26.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSControlVolumeView.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"

@interface FSControlVolumeView()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) UILabel *soundtrackLabel;
@property (nonatomic, strong) UISlider *soundtrackSlider;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UISlider *scoreSlider;

@property (nonatomic, strong) UIVisualEffectView *effectView;

@property (nonatomic, assign) CGFloat scroeVolume;
@property (nonatomic, assign) CGFloat soundtrackVolume;


@end

@implementation FSControlVolumeView

- (instancetype)initWithFrame:(CGRect)frame scroe:(CGFloat)scroeVolume soundtrack:(CGFloat)soundtrackVolume {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _scroeVolume = scroeVolume;
        _soundtrackVolume = soundtrackVolume;
        [self initBaseUI];
    }
    return self;
}

- (void)initBaseUI {
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 145, self.frame.size.width, 145)];
    _contentView.backgroundColor = [UIColor clearColor];
    //_contentView.alpha = 0.7;
    [self addSubview:_contentView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:(UIBlurEffectStyleLight)];
    _effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [_effectView setFrame:_contentView.bounds];
    [_contentView addSubview:_effectView];
    
    _soundtrackLabel = [[UILabel alloc] initWithFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? _contentView.frame.size.width-15 : 15, 23, 0, 27)];
    _soundtrackLabel.backgroundColor = [UIColor clearColor];
    _soundtrackLabel.font = [UIFont systemFontOfSize:15];
    _soundtrackLabel.textColor = FSHexRGB(0x292929);
    _soundtrackLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"Original"];//NSLocalizedString(@"Original", nil);
    [_soundtrackLabel sizeToFit];
    _soundtrackLabel.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? _contentView.frame.size.width-15-_soundtrackLabel.frame.size.width : 15, 23, _soundtrackLabel.frame.size.width, 27);
    [_contentView addSubview:_soundtrackLabel];
    
    _soundtrackSlider = [[UISlider alloc] initWithFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 15 : CGRectGetMaxX(_soundtrackLabel.frame)+15, 23, _contentView.frame.size.width-CGRectGetWidth(_soundtrackLabel.frame)-15-15-15, 27)];
    _soundtrackSlider.value = _soundtrackVolume;
    _soundtrackSlider.minimumTrackTintColor = FSHexRGB(0xFACE15);
    _soundtrackSlider.maximumTrackTintColor = FSHexRGB(0x000000);
    _soundtrackSlider.thumbTintColor = FSHexRGB(0xFFFFFF);
    [_soundtrackSlider addTarget:self action:@selector(changeSoundtrack) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_soundtrackSlider];
    
    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? _contentView.frame.size.width-15 : 15, CGRectGetMaxY(_soundtrackLabel.frame)+30, 0, 27)];
    _scoreLabel.backgroundColor = [UIColor clearColor];
    _scoreLabel.font = [UIFont systemFontOfSize:15];
    _scoreLabel.textColor = FSHexRGB(0x292929);
    _scoreLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"Music"];//NSLocalizedString(@"Music", nil);
    [_scoreLabel sizeToFit];
    _scoreLabel.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? _contentView.frame.size.width-15-_scoreLabel.frame.size.width : 15, _scoreLabel.frame.origin.y, _scoreLabel.frame.size.width, _scoreLabel.frame.size.height);
    [_contentView addSubview:_scoreLabel];
    
    _scoreSlider = [[UISlider alloc] initWithFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 15 : CGRectGetMaxX(_scoreLabel.frame)+15, CGRectGetMaxY(_soundtrackLabel.frame)+30, _contentView.frame.size.width-CGRectGetWidth(_scoreLabel.frame)-15-15-15, 27)];
    _scoreSlider.value = _scroeVolume;
    _scoreSlider.minimumTrackTintColor = FSHexRGB(0xFACE15);
    _scoreSlider.maximumTrackTintColor = FSHexRGB(0x000000);
    _scoreSlider.thumbTintColor = FSHexRGB(0x92908D);
    [_scoreSlider addTarget:self action:@selector(changeScore) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_scoreSlider];
    
    if (_soundtrackVolume < 0) {
        _soundtrackSlider.enabled = NO;
        _scoreSlider.enabled = YES;
    }
    else {
        _soundtrackSlider.enabled = YES;
        _scoreSlider.enabled = NO;
    }
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-60)/2, CGRectGetMinY(_contentView.frame)-20-30, 60, 30)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"Volume"];//NSLocalizedString(@"Volume", nil);
    _titleLabel.shadowColor = [UIColor blackColor];
    //阴影偏移  x，y为正表示向右下偏移
    _titleLabel.shadowOffset = CGSizeMake(1, 1);
    [self addSubview:_titleLabel];
    
    _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishButton.backgroundColor = [UIColor clearColor];
    _finishButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 20 : self.frame.size.width-20-54, CGRectGetMinY(_contentView.frame)-20-30, 54, 30);
    [_finishButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
    [_finishButton addTarget:self action:@selector(finishClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_finishButton];
    
}

- (void)finishClick {
    if ([self.delegate respondsToSelector:@selector(FSControlVolumeViewChangeFinished)]) {
        [self.delegate FSControlVolumeViewChangeFinished];
    }
}

/**
 视频音量
 */
- (void)changeSoundtrack {
    if ([self.delegate respondsToSelector:@selector(FSControlVolumeViewChangeSoundtrack:)]) {
        [self.delegate FSControlVolumeViewChangeSoundtrack:_soundtrackSlider.value];
    }
}

/**
 配乐音量
 */
- (void)changeScore {
    if ([self.delegate respondsToSelector:@selector(FSControlVolumeViewChangeScore:)]) {
        [self.delegate FSControlVolumeViewChangeScore:_scoreSlider.value];
    }
}

@end
