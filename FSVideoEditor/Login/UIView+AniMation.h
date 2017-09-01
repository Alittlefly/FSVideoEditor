//
//  UIView+AniMation.h
//  FlyShow
//
//  Created by gaochao on 15/4/9.
//  Copyright (c) 2015年 高超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (AniMation)<CAAnimationDelegate>

-(void)addRotateAnimation:(CGFloat)duration;


@end
