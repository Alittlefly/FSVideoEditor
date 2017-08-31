//
//  FSAnimationNavController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/3.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSAnimationNavController.h"
#import "FSPresentAnimator.h"
#import "FSDismissAnimator.h"

@interface FSAnimationNavController ()
{
    CGFloat _defaultFraction;
    
    UIPanGestureRecognizer *_pan;
}
@property(nonatomic,strong)UIPercentDrivenInteractiveTransition *percentInter;
@property(nonatomic,assign)CGFloat fraction;
@end

@implementation FSAnimationNavController
-(instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    if (self = [super initWithRootViewController:rootViewController]) {
        [self setTransitioningDelegate:self];
        _defaultFraction = 0.5;
        
        [self setEnablePanToDismiss:YES];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.interactivePopGestureRecognizer.enabled = NO;
    [self.view setBackgroundColor:[UIColor clearColor]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

}
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [super pushViewController:viewController animated:animated];
    
    if ([self.childViewControllers count] > 1) {
        [self setEnablePanToDismiss:NO];
    }
    
}
-(UIViewController *)popViewControllerAnimated:(BOOL)animated{
    
    UIViewController *willPop =  [super popViewControllerAnimated:animated];
    
    if ([self.childViewControllers count] == 1) {
        [self setEnablePanToDismiss:YES];
    }
    
    return willPop;
}
-(void)initPanToDismissGesture{
    if (!_pan) {
        UIPanGestureRecognizer *screenPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlerPan:)];
        _pan = screenPan;
    }

    [self.view addGestureRecognizer:_pan];
}
-(void)setEnablePanToDismiss:(BOOL)enablePanToDismiss{
    if (enablePanToDismiss) {
        [self initPanToDismissGesture];
    }else{
        if (_pan) {
            [self.view removeGestureRecognizer:_pan];
        }
    }
}

-(void)handlerPan:(UIPanGestureRecognizer *)gestureRecognizer{
    
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.percentInter = [UIPercentDrivenInteractiveTransition new];
            [self dismissViewControllerAnimated:YES completion:nil];
            
            break;
        case UIGestureRecognizerStateChanged: {
            // 2. Calculate the percentage of guesture
            CGFloat fraction = ABS(translation.y)/ CGRectGetHeight(self.view.bounds);
            //Limit it between 0 and 1
            fraction = fminf(fmaxf(fraction, 0.0), 1.0);
             self.fraction = fraction;
            [self.percentInter updateInteractiveTransition:fraction];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            CGFloat cfraction = _defaultFraction;
            
            if (cfraction == 0) {
                cfraction = 0.5;
            }
            
            if (self.fraction >= cfraction) {
                [self.percentInter finishInteractiveTransition];
            }else{
                [self.percentInter cancelInteractiveTransition];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled: {
            [self.percentInter cancelInteractiveTransition];
            break;
        }
        default:
            break;
    }
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [FSPresentAnimator new];
}
-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    return self.percentInter;
}
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [FSDismissAnimator new];
}

-(UIModalPresentationStyle)modalPresentationStyle{
    return UIModalPresentationOverFullScreen;
}
-(void)dealloc{
    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
@end
