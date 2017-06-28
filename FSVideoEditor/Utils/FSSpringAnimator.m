//
//  FSSpringAnimator.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSSpringAnimator.h"
#import "FSVideoFxController.h"
@interface FSSpringAnimator()
@property(nonatomic,assign)UIViewController *sourceVc;
@end
@implementation FSSpringAnimator
+(instancetype)initWithSourceVc:(UIViewController *)sourceVc{
    if (!sourceVc) {
        return nil;
    }
    
    FSSpringAnimator *dissolve = [[FSSpringAnimator alloc] init];
    dissolve.sourceVc = sourceVc;
    return dissolve;
}
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}
-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
        
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    if ([fromViewController isKindOfClass:[FSVideoFxController class]]) {
        FSVideoFxController *fxController = (FSVideoFxController *)fromViewController;
        [containerView addSubview:fxController.view];
        [fxController.videoFxView setHidden:YES];
        CGRect toFrame = containerView.bounds;
        [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:(UIViewKeyframeAnimationOptionCalculationModeLinear) animations:^{
            [fxController.prewidow setFrame:toFrame];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
        
    }
}
@end
