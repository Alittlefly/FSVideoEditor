//
//  FSAnimationNavController.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/3.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSAnimationNavController : UINavigationController<UIViewControllerTransitioningDelegate>
@property(nonatomic,assign)BOOL enablePanToDismiss;
@end
