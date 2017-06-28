//
//  FSDissolveAnimator.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDissolveAnimator.h"
#import "FSPublisherController.h"
#import "FSVideoFxController.h"
@interface FSDissolveAnimator()
@property(nonatomic,assign)UIViewController *sourceVc;
@end
@implementation FSDissolveAnimator
+(instancetype)initWithSourceVc:(UIViewController *)sourceVc{
    if (!sourceVc) {
        return nil;
    }
    
    FSDissolveAnimator *dissolve = [[FSDissolveAnimator alloc] init];
    dissolve.sourceVc = sourceVc;
    return dissolve;
}
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}
-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    if ([self.sourceVc isKindOfClass:[FSPublisherController class]]) {
        FSPublisherController *publish = (FSPublisherController *)self.sourceVc;
        [publish.toolView setHidden:YES];
        
        UIView *containerView = [transitionContext containerView];
        CGRect orignalFrame = publish.prewidow.frame;
        FSVideoFxController *toViewController = (FSVideoFxController *) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        CGRect toFrame = toViewController.controlView.frame;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            [publish.prewidow setFrame:toFrame];
        } completion:^(BOOL finished) {
            [containerView addSubview:toViewController.view];
            [publish.prewidow setFrame:orignalFrame];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}
@end
