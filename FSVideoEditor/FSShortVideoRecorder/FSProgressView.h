//
//  FSProgressView.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/23.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSProgressView : UIView

@property (nonatomic, strong) UIColor *progressViewColor;

- (void)setProgress:(CGFloat)progress animated:(BOOL)isAnimated;


@end
