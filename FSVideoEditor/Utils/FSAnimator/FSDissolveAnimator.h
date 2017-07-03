//
//  FSDissolveAnimator.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface FSDissolveAnimator : NSObject<UIViewControllerAnimatedTransitioning>
+(instancetype)initWithSourceVc:(UIViewController *)sourceVc;
@end
