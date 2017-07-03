//
//  FSPresentAnimator.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/3.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSPresentAnimator.h"

@implementation FSPresentAnimator
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}
-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // 终点视图的位置
    CGRect fromFrame = [transitionContext initialFrameForViewController:fromViewController];
    CGRect offScreenFrame = fromFrame;
    //先将其设置到屏幕外边，通过动画进入
    offScreenFrame.origin.y = offScreenFrame.size.height;
    toViewController.view.frame = offScreenFrame;
    [containerView addSubview:toViewController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        [toViewController.view setFrame:fromFrame];
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}
@end
