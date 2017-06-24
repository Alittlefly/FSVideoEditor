//
//  FSVideoClipProgress.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoClipProgress.h"
@interface FSVideoClipProgress()
@property(nonatomic,strong)UIView *line;
@property(nonatomic,strong)UIView *backContent;
@end
@implementation FSVideoClipProgress
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self creatSubViews:frame];
    }
    return self;
}
-(void)creatSubViews:(CGRect)frame{
    _backContent = [[UIView alloc] initWithFrame:CGRectMake(0, 6.5, CGRectGetWidth(frame), CGRectGetHeight(frame) - 13)];
    [self addSubview:_backContent];
    
     _line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, CGRectGetHeight(frame))];
    [_line setBackgroundColor:FSHexRGB(0xFACE15)];
     _line.layer.cornerRadius = 2.5;
     _line.layer.masksToBounds = YES;
    [self addSubview:_line];
}
-(void)setBackGroundView:(UIView *)backGroundView{
    if (!backGroundView) {
        return;
    }
    [backGroundView setFrame:_backContent.bounds];
    [_backContent addSubview:backGroundView];
}
@end
