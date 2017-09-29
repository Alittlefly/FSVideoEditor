//
//  UIButton+Reverse.m
//  FSVideoEditor
//
//  Created by stu on 2017/9/29.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "UIButton+Reverse.h"

@implementation UIButton (Reverse)

//更改button的image和title布局
- (void)reverseButton
{
    CGPoint buttonBoundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    // 找出imageView最终的center
    
    CGPoint endImageViewCenter = CGPointMake(buttonBoundsCenter.x + self.bounds.size.width/2-self.imageView.bounds.size.width/2, buttonBoundsCenter.y);
    
    // 找出titleLabel最终的center
    
    CGPoint endTitleLabelCenter = CGPointMake(buttonBoundsCenter.x-self.bounds.size.width/2 + self.titleLabel.bounds.size.width/2, buttonBoundsCenter.y);
    
    // 取得imageView最初的center
    
    CGPoint startImageViewCenter = self.imageView.center;
    
    // 取得titleLabel最初的center
    
    CGPoint startTitleLabelCenter = self.titleLabel.center;
    
    // 设置imageEdgeInsets
    
    CGFloat imageEdgeInsetsTop = endImageViewCenter.y - startImageViewCenter.y;
    
    CGFloat imageEdgeInsetsLeft = endImageViewCenter.x - startImageViewCenter.x;
    
    CGFloat imageEdgeInsetsBottom = -imageEdgeInsetsTop;
    
    CGFloat imageEdgeInsetsRight = -imageEdgeInsetsLeft;
    
    self.imageEdgeInsets = UIEdgeInsetsMake(imageEdgeInsetsTop, MAX(0, imageEdgeInsetsLeft), imageEdgeInsetsBottom, MAX(0, imageEdgeInsetsRight));
    
    // 设置titleEdgeInsets
    
    CGFloat titleEdgeInsetsTop = endTitleLabelCenter.y-startTitleLabelCenter.y;
    
    CGFloat titleEdgeInsetsLeft = endTitleLabelCenter.x - startTitleLabelCenter.x;
    
    CGFloat titleEdgeInsetsBottom = -titleEdgeInsetsTop;
    
    CGFloat titleEdgeInsetsRight = -titleEdgeInsetsLeft;
    
    self.titleEdgeInsets = UIEdgeInsetsMake(titleEdgeInsetsTop,MAX(0, titleEdgeInsetsLeft) , titleEdgeInsetsBottom,MAX(0, titleEdgeInsetsRight));
}

@end
