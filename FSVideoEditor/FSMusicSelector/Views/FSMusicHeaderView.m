//
//  FSMusicHeaderView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicHeaderView.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"

@interface FSMusicTypeButton : UIButton

@end
@implementation FSMusicTypeButton

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initStyle];
    }
    return self;
}
-(instancetype)init{
    if (self = [super init]) {
        [self initStyle];
    }
    return self;
}
-(void)initStyle{
    [self.titleLabel setTextAlignment:(NSTextAlignmentCenter)];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setTitleColor:FSHexRGB(0xb8b9bd) forState:(UIControlStateSelected)];
    [self setTitleColor:FSHexRGB(0x0bc2c6) forState:(UIControlStateNormal)];
}
@end

@interface FSMusicHeaderView()
{
    BOOL _opend;
}
@property(nonatomic,strong)FSMusicTypeButton *hotMusicButton;
@property(nonatomic,strong)FSMusicTypeButton *likeMusicButton;
@property(nonatomic,strong)UIButton *showAllButton;
@property(nonatomic,strong)UIView *hline;
@property(nonatomic,strong)UIView *vline;
@end
@implementation FSMusicHeaderView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _opend = NO;
        [self creatSubviews:frame];
    }
    return self;
}
-(void)creatSubviews:(CGRect)frame{
    if (!_hline) {
        _hline = [UIView new];
        [_hline setBackgroundColor:FSHexRGB(0xe4e4e4)];
        [self addSubview:_hline];
    }
    [_hline setFrame:CGRectMake(10, 161, CGRectGetWidth(frame) - 20, 0.5)];

    if (!_hotMusicButton) {
        _hotMusicButton = [[FSMusicTypeButton alloc] init];
        [_hotMusicButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"HotMusic"] forState:(UIControlStateNormal)];
        [self addSubview:_hotMusicButton];
    }
    
    [_hotMusicButton setFrame:CGRectMake(0, CGRectGetHeight(frame) - 52, CGRectGetWidth(frame)/2.0- 0.5, 52)];

    if (!_vline) {
        _vline = [UIView new];
        [_vline setBackgroundColor:FSHexRGB(0xe4e4e4)];
        [self addSubview:_vline];
    }
    [_vline setFrame:CGRectMake(CGRectGetMidX(frame), 161 + 18.5, 1.0, 15.0)];

    if (!_likeMusicButton) {
        _likeMusicButton = [[FSMusicTypeButton alloc] init];
        [_likeMusicButton setBackgroundColor:[UIColor clearColor]];
        [_likeMusicButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"likeMusic"] forState:(UIControlStateNormal)];
        [self addSubview:_likeMusicButton];
    }
    [_likeMusicButton setFrame:CGRectMake(CGRectGetWidth(frame)/2.0 + 0.5, CGRectGetHeight(frame) - 52, CGRectGetWidth(frame)/2.0- 0.5, 52)];

}
-(void)setItems:(NSArray<FSMusicType *> *)items{
    _items = items;
}
@end
