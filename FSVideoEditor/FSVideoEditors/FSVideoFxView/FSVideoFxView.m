//
//  FSVideoFxView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoFxView.h"

@interface FSLineButton : UIButton
{
    UIColor *_lineSelectColor;
}
@property(nonatomic,strong)UIView *line;
@end
@implementation FSLineButton
-(UIView *)line{
    if (!_line) {
         _line = [UIView new];
        [_line setAlpha:0];
    }
    return _line;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _lineSelectColor = FSHexRGB(0xface15);
        [self addSubview:self.line];
        
        [self setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected)];
        [self setTitleColor:FSHexRGBAlpha(0xffffff, 0.8) forState:(UIControlStateNormal)];
        
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [_line setBackgroundColor:_lineSelectColor];
    [_line setFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 2, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    [UIView animateWithDuration:0.4 animations:^{
        [_line setAlpha:selected];
    }];
    
}
@end


@interface FSVideoFxView()
{
    FSLineButton *_currentSelectButton;
}
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)NSArray *videofxs;
@property(nonatomic,strong)NSArray *videofuncs;

@end

@implementation FSVideoFxView
-(instancetype)initWithFrame:(CGRect)frame fxs:(NSArray *)fxs{
    if (self = [super initWithFrame:frame]) {
       
         self.videofxs = fxs;
        
        [self creatSubiviews];
        
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

-(void)creatSubiviews{
    CGRect sframe = self.bounds;
    
    // content
    _contentView = [[UIView alloc] initWithFrame:sframe];
    [_contentView setBackgroundColor:FSHexRGB(0x000f1e)];
    [self addSubview:_contentView];
    
    
    // bottom
    CGFloat bottomH = 45.0;
     _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(sframe) - 45, CGRectGetWidth(sframe), bottomH)];
    [_bottomView setBackgroundColor:FSHexRGB(0x242630)];
    [self addSubview:_bottomView];
    
    FSLineButton *fxButton = [[FSLineButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(sframe)/2.0 - 1, 45)];
    [fxButton setTitle:@"滤镜特效" forState:UIControlStateNormal];
    [fxButton addTarget:self action:@selector(showFx:) forControlEvents:(UIControlEventTouchUpInside)];
    fxButton.tag = 1;
    [fxButton setSelected:YES];
    _currentSelectButton = fxButton;
    [_bottomView addSubview:fxButton];
    
    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(sframe), (bottomH - 12)/2.0, 1.0, 12)];
    [sepLine setBackgroundColor:[UIColor blackColor]];
    [sepLine setBackgroundColor:FSHexRGBAlpha(0xf5f5f5,0.2)];
    [_bottomView addSubview:sepLine];
    
    FSLineButton *timefxButton = [[FSLineButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(sframe)/2.0+1, 0, CGRectGetWidth(sframe)/2.0 - 1, 45)];
    [timefxButton setTitle:@"时间特效" forState:UIControlStateNormal];
    [timefxButton addTarget:self action:@selector(showFx:) forControlEvents:(UIControlEventTouchUpInside)];
    timefxButton.tag = 2;
    [_bottomView addSubview:timefxButton];
    
}

#pragma mark - 
-(void)showFx:(FSLineButton *)button{
    if ([_currentSelectButton isEqual:button]) {
        return;
    }
    [_currentSelectButton setSelected:NO];
    _currentSelectButton = button;
    [_currentSelectButton setSelected:YES];
    
    NSInteger tag = _currentSelectButton.tag;
    
    // 
}

@end
