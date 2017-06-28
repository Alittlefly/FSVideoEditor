//
//  FSControlView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSControlView.h"
@interface FSControlView()
@property(nonatomic,strong)UIImageView *pauseImage;
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,assign)UIView *backgroundView;
@end
@implementation FSControlView

-(UIImageView *)pauseImage{
    if (!_pauseImage) {
        _pauseImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fx_play"]];
    }
    return _pauseImage;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self creatSubview];
        
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}
-(void)creatSubview{
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_contentView];
    [self addSubview:self.pauseImage];
}
-(void)setBackgroundView:(UIView *)backgroundView{
    if (!backgroundView) {
        return;
    }
    _backgroundView = backgroundView;
    [backgroundView setFrame:self.bounds];
    [self.contentView addSubview:backgroundView];
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.contentView setFrame:self.bounds];
    
    [self.pauseImage setFrame:CGRectMake(0, 0, 26, 31)];
    [self.pauseImage setCenter:CGPointMake(CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0)];
//
    if (_backgroundView) {
        [_backgroundView setFrame:self.contentView.bounds];
    }
}

-(void)setState:(BOOL)play{
    [self.pauseImage setHidden:play];
}
@end
