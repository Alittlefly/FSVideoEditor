//
//  FSAddChallengeTextField.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/9/7.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSAddChallengeTextField.h"
#import "FSPublishSingleton.h"

@implementation FSAddChallengeTextField

//UITextField 文字与输入框的距离
- (CGRect)textRectForBounds:(CGRect)bounds{
    if ([FSPublishSingleton sharedInstance].isAutoReverse) {
        return CGRectInset(bounds, 5+self.rightView.frame.size.width+3, 0);
    } else {
        return CGRectInset(bounds, 5+self.leftView.frame.size.width+3, 0);
    }
}

// 控制文本的位置
- (CGRect)editingRectForBounds:(CGRect)bounds{
    if ([FSPublishSingleton sharedInstance].isAutoReverse) {
        return CGRectInset(bounds, 5+self.rightView.frame.size.width+3, 0);
    } else {
        return CGRectInset(bounds, 5+self.leftView.frame.size.width+3, 0);
    }
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += 5; //像右边偏5
    return iconRect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect iconRect = [super rightViewRectForBounds:bounds];
    iconRect.origin.x -= 5; //像左边偏5
    return iconRect;
}

@end
