//
//  FSDismissAnimator.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/3.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDismissAnimator.h"

@implementation FSDismissAnimator
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}
-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    // 视图的位置
    CGRect fromFrame = [transitionContext initialFrameForViewController:fromViewController];
    
    CGRect offScreenFrame = fromFrame;
    //先将其设置到屏幕外边，通过动画进入
    offScreenFrame.origin.y = offScreenFrame.size.height;
    [containerView addSubview:fromViewController.view];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
         fromViewController.view.frame = offScreenFrame;
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}
- (void)animationEnded:(BOOL) transitionCompleted{
    
}
@end
