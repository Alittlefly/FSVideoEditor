//
//  FSControlVolumeView.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/26.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSControlVolumeView.h"
//#import "AMBlurView.h"

@interface FSControlVolumeView()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) UILabel *soundtrackLabel;
@property (nonatomic, strong) UISlider *soundtrackSlider;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UISlider *scoreSlider;

@property (nonatomic, strong) UIVisualEffectView *effectView;

@end

@implementation FSControlVolumeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self initBaseUI];
    }
    return self;
}

- (void)initBaseUI {
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 145, self.frame.size.width, 145)];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.alpha = 0.9;
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
    _soundtrackLabel.textColor = [UIColor blackColor];
    _soundtrackLabel.text = @"原声";
    [_soundtrackLabel sizeToFit];
    _soundtrackLabel.frame = CGRectMake(15, 23, _soundtrackLabel.frame.size.width, 27);
    [_contentView addSubview:_soundtrackLabel];
    
    _soundtrackSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_soundtrackLabel.frame)+15, 23, _contentView.frame.size.width-CGRectGetMaxX(_soundtrackLabel.frame)-15-15, 27)];
    _soundtrackSlider.value = 0.5;
    _soundtrackSlider.minimumTrackTintColor = [UIColor orangeColor];
    _soundtrackSlider.maximumTrackTintColor = [UIColor blackColor];
    _soundtrackSlider.thumbTintColor = [UIColor redColor];
    [_soundtrackSlider addTarget:self action:@selector(changeSoundtrack) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_soundtrackSlider];
    
    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_soundtrackLabel.frame)+30, 0, 27)];
    _scoreLabel.backgroundColor = [UIColor clearColor];
    _scoreLabel.font = [UIFont systemFontOfSize:15];
    _scoreLabel.textColor = [UIColor blackColor];
    _scoreLabel.text = @"配乐";
    [_scoreLabel sizeToFit];
    _scoreLabel.frame = CGRectMake(_scoreLabel.frame.origin.x, _scoreLabel.frame.origin.y, _scoreLabel.frame.size.width, _scoreLabel.frame.size.height);
    [_contentView addSubview:_scoreLabel];
    
    _scoreSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_scoreLabel.frame)+15, CGRectGetMaxY(_soundtrackLabel.frame)+30, _contentView.frame.size.width-CGRectGetMaxX(_scoreLabel.frame)-15-15, 27)];
    _scoreSlider.value = 0.5;
    _scoreSlider.minimumTrackTintColor = [UIColor orangeColor];
    _scoreSlider.maximumTrackTintColor = [UIColor blackColor];
    _scoreSlider.thumbTintColor = [UIColor redColor];
    [_scoreSlider addTarget:self action:@selector(changeScore) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_scoreSlider];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-60)/2, CGRectGetMinY(_contentView.frame)-20-30, 60, 30)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont systemFontOfSize:18];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"音量";
    [self addSubview:_titleLabel];
    
    _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishButton.backgroundColor = [UIColor greenColor];
    _finishButton.frame = CGRectMake(self.frame.size.width-20-54, CGRectGetMinY(_contentView.frame)-20-30, 54, 30);
    [_finishButton addTarget:self action:@selector(finishClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_finishButton];
    
}

- (void)finishClick {
    if ([self.delegate respondsToSelector:@selector(FSControlVolumeViewChangeFinished)]) {
        [self.delegate FSControlVolumeViewChangeFinished];
    }
}

- (void)changeSoundtrack {
    if ([self.delegate respondsToSelector:@selector(FSControlVolumeViewChangeSoundtrack:)]) {
        [self.delegate FSControlVolumeViewChangeSoundtrack:_soundtrackSlider.value];
    }
}

- (void)changeScore {
    if ([self.delegate respondsToSelector:@selector(FSControlVolumeViewChangeScore:)]) {
        [self.delegate FSControlVolumeViewChangeScore:_scoreSlider.value];
    }
}

@end
