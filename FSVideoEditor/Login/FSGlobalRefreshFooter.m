//
//  FSGlobalRefreshFooter.m
//  FlyShow
//
//  Created by gaochao on 15/11/27.
//  Copyright (c) 2015年 高超. All rights reserved.
//

#import "FSGlobalRefreshFooter.h"
#import "UIView+AniMation.h"

@interface FSGlobalRefreshFooter()
@property (weak, nonatomic) UIImageView *logo;
@end
@implementation FSGlobalRefreshFooter
-(void)prepare
{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = 50;
    // logo
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Garage_Loading"]];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    [logo.layer setCornerRadius:CGRectGetWidth(logo.frame)/2];
    [logo.layer setMasksToBounds:YES];
  
    self.logo = logo;
    [self addSubview:logo];
}
-(void)placeSubviews
{
    [super placeSubviews];
    
    self.logo.center = CGPointMake(self.mj_w * 0.5,self.mj_h * 0.5 - self.logo.mj_h * 0.5 + 10);
    
}

- (void)startLogoAnimation
{
    [self.logo addRotateAnimation:0.5];
 
}
- (void)stopLogoAnimation
{
    [self.logo.layer removeAllAnimations];
}
#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
//    NSLog(@"ContentOffsetDidChange %@",change);
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
//    NSLog(@"ContentSizeDidChange %@",change);
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
//    NSLog(@"PanStateDidChangec %@",change);
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateIdle:
            [self stopLogoAnimation];
            break;
        case MJRefreshStatePulling:
            [self stopLogoAnimation];
            break;
        case MJRefreshStateRefreshing:
            [self startLogoAnimation];
            break;
        case MJRefreshStateNoMoreData:
            [self stopLogoAnimation];
        default:
            break;
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
}

@end
