//
//  FSLoadingView.m
//  FlyShow
//
//  Created by shawnfeng on 16/1/9.
//  Copyright © 2016年 高超. All rights reserved.
//

#import "FSEditorLoading.h"
#import "FSShortLanguage.h"
#import "FSVideoEditorCommenData.h"
@interface FSEditorLoading()

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UIView  *loadingBack;
@property(nonatomic,strong)UIActivityIndicatorView *indictor;
@property(nonatomic,strong)UIView  *enableView;
@end
@implementation FSEditorLoading

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)dealloc
{
}
-(UIView *)enableView
{
    if (!_enableView) {
         _enableView = [[UIView alloc] init];
        [_enableView setUserInteractionEnabled:YES];
    }
    return _enableView;
}
-(UILabel *)titleLabel
{
    if (!_titleLabel) {
         _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setText:[FSShortLanguage CustomLocalizedStringFromTable:@"Loading"]];
    }
    return _titleLabel;
}


-(UIView *)loadingBack
{
    if (!_loadingBack) {
        _loadingBack = [[UIView alloc] init];
        [_loadingBack setBackgroundColor:FSHexRGBAlpha(0x000000, 0.8)];
        [self addSubview:_loadingBack];
    }
    return _loadingBack;
}
-(UIActivityIndicatorView *)indictor
{
    if (!_indictor) {
        _indictor = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
        [_indictor setFrame:CGRectMake(0, 0, 20, 20)];
        _indictor.hidesWhenStopped = YES;
    }
    return _indictor;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self creatSubViews:frame];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self creatSubViews:frame];
}
-(void)creatSubViews:(CGRect)frame
{
    [self.enableView setFrame:self.bounds];
    
    [self.loadingBack setFrame:CGRectMake((CGRectGetWidth(frame) - 120)/2.0, (CGRectGetHeight(frame)- 120)/2.0 - 60, 120, 120)];
    [self.loadingBack.layer setCornerRadius:8];
    [self.loadingBack.layer setMasksToBounds:YES];
    
    [self.indictor setFrame:CGRectMake(50, 40, 20, 20)];
    
    [self.titleLabel setFrame:CGRectMake(0, 80, 120, 20)];

    [self.loadingBack addSubview:self.indictor];
    [self.loadingBack addSubview:self.titleLabel];
}
-(BOOL)isLoading{
    return [self.indictor isAnimating];
}

-(void)loadingViewShow;
{
    [self.indictor startAnimating];
}
-(void)loadingViewhide;
{
    [self.indictor stopAnimating];
    [self removeFromSuperview];
}
@end
