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
    _contentView.backgroundColor = FSHexRGB(0xFFFFFF);//[UIColor whiteColor];
    _contentView.alpha = 0.7;
    [self addSubview:_contentView];
    
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)) {
        /*
         毛玻璃的样式(枚举)
         UIBlurEffectStyleExtraLight,
         UIBlurEffectStyleLight,
         UIBlurEffectStyleDark
         */
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _effectView.frame = CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height);
        _effectView.alpha = 0.7;
        
        [_contentView addSubview:_effectView];
    }else{
//        [self setBlurView:[AMBlurView new]];
//        [[self blurView] setFrame:_bgView.bounds];
//        [[self blurView] setAlpha:1];
//        [[self blurView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//        [_bgView addSubview:[self blurView]];
    }

    
    _soundtrackLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 23, 0, 27)];
    _soundtrackLabel.backgroundColor = [UIColor clearColor];
    _soundtrackLabel.font = [UIFont systemFontOfSize:15];
    _soundtrackLabel.textColor = [UIColor whiteColor];
    _soundtrackLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"Original"];//NSLocalizedString(@"Original", nil);
    [_soundtrackLabel sizeToFit];
    _soundtrackLabel.frame = CGRectMake(15, 23, _soundtrackLabel.frame.size.width, 27);
    [_contentView addSubview:_soundtrackLabel];
    
    _soundtrackSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_soundtrackLabel.frame)+15, 23, _contentView.frame.size.width-CGRectGetMaxX(_soundtrackLabel.frame)-15-15, 27)];
    _soundtrackSlider.value = _soundtrackVolume;
    _soundtrackSlider.minimumTrackTintColor = [UIColor orangeColor];
    _soundtrackSlider.maximumTrackTintColor = [UIColor blackColor];
    _soundtrackSlider.thumbTintColor = FSHexRGB(0x0BC2C6);
    [_soundtrackSlider addTarget:self action:@selector(changeSoundtrack) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_soundtrackSlider];
    
    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_soundtrackLabel.frame)+30, 0, 27)];
    _scoreLabel.backgroundColor = [UIColor clearColor];
    _scoreLabel.font = [UIFont systemFontOfSize:15];
    _scoreLabel.textColor = [UIColor whiteColor];
    _scoreLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"Music"];//NSLocalizedString(@"Music", nil);
    [_scoreLabel sizeToFit];
    _scoreLabel.frame = CGRectMake(_scoreLabel.frame.origin.x, _scoreLabel.frame.origin.y, _scoreLabel.frame.size.width, _scoreLabel.frame.size.height);
    [_contentView addSubview:_scoreLabel];
    
    _scoreSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_scoreLabel.frame)+15, CGRectGetMaxY(_soundtrackLabel.frame)+30, _contentView.frame.size.width-CGRectGetMaxX(_scoreLabel.frame)-15-15, 27)];
    _scoreSlider.value = _scroeVolume;
    _scoreSlider.minimumTrackTintColor = [UIColor orangeColor];
    _scoreSlider.maximumTrackTintColor = [UIColor blackColor];
    _scoreSlider.thumbTintColor = FSHexRGB(0x0BC2C6);
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
    _finishButton.frame = CGRectMake(self.frame.size.width-20-54, CGRectGetMinY(_contentView.frame)-20-30, 54, 30);
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
