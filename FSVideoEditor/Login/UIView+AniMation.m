//
//  UIView+AniMation.m
//  FlyShow
//
//  Created by gaochao on 15/4/9.
//  Copyright (c) 2015年 高超. All rights reserved.
//

#import "UIView+AniMation.h"
@implementation UIView (AniMation)

-(void)addRotateAnimation:(CGFloat)duration
{
    [self.layer removeAllAnimations];
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = INT64_MAX; //旋转次数
    rotationAnimation.cumulative = NO;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:rotationAnimation forKey:@"transform.rotation.z"];
}

-(void)addAnimationOnViewEndPoint:(CGPoint)endPoint delegate:(id)delegate
{
    CAAnimationGroup *group = [CAAnimationGroup animation];
    
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.2, 0.2, 1.0)];
    scaleAnim.repeatCount = MAXFLOAT;
    
    CABasicAnimation *rotate =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    rotate.fromValue = [NSNumber numberWithFloat:0.f];
    rotate.toValue =  [NSNumber numberWithFloat: M_PI *2];
    rotate.autoreverses = NO;
    rotate.repeatCount = MAXFLOAT;
    rotate.speed = 2.0f;
    
    CAKeyframeAnimation *positionAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:self.layer.position];
    [bezierPath addQuadCurveToPoint:endPoint controlPoint:CGPointMake(endPoint.x, 0)];
    positionAnim.path = bezierPath.CGPath;
    positionAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    positionAnim.autoreverses = NO;
    positionAnim.repeatCount = 1;
    
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.duration = 1.0;
    
    [group setAnimations:@[scaleAnim,rotate,positionAnim]];
    [group setDelegate:delegate];
    [self.layer addAnimation:group forKey:@"dropAnimation"];
}
-(void)bounceAnimation_twoDelegate:(id<CAAnimationDelegate>)delegate bounceHeight:(CGFloat)bounceHeight
{
    //Y
    NSArray *times = @[@(0.0),@(0.33),@(0.6),@(0.75),@(1)];//,@(1)];

    CAKeyframeAnimation *trans = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    NSArray *values = @[@(-15),@(-bounceHeight),@(0),@(5),@(0)];//
    trans.values = values;
    trans.keyTimes = times;
    trans.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    //Alpha
    CAKeyframeAnimation *alpha = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    NSArray *alphaValues = @[@(0.0),@(0.2),@(0.4),@(0.6),@(1)];
    alpha.values = alphaValues;
    alpha.keyTimes = times;
    alpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CAKeyframeAnimation *scaleXAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    NSArray *scaleXValues = @[@(0.12),@(1.2),@(1),@(1),@(1)];
    scaleXAnimation.values = scaleXValues;
    scaleXAnimation.keyTimes = times;// @[@(0.0),@(1.0/3.0),@(9.0/15.0),@(12.0/15.0),@(1)];//,@(1)];scaleXtimes;
    scaleXAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CAKeyframeAnimation *scaleYAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    NSArray *scaleYValues = @[@(0.12),@(1.2),@(1),@(0.9),@(1)];
    scaleYAnimation.values = scaleYValues;
    scaleYAnimation.keyTimes = times;//@[@(0.0),@(1.0/3.0),@(9.0/15.0),@(12.0/15.0),@(1)];//,@(1)];scaleYtimes;
    scaleYAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CAAnimationGroup *aGroup = [CAAnimationGroup animation];
    [aGroup setAnimations:@[trans,scaleXAnimation,scaleYAnimation,alpha]];
    aGroup.repeatCount = 1;
    aGroup.duration = 0.53;
    aGroup.fillMode = kCAFillModeForwards;
    [aGroup setDelegate:delegate];
    [aGroup setValue:@"bounces" forKey:@"currentAnimation"];

    [self.layer addAnimation:aGroup forKey:nil];
    
}

@end
