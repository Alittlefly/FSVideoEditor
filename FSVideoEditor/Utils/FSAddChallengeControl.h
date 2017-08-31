//
//  FSAddChallengeControl.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/8/31.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSAddChallengeControl : UIButton

@property (nonatomic, assign) float maxWidth;

- (void)setLeftImage:(UIImage *)leftImage title:(NSString *)title rightImage:(UIImage *)rightImage;

@end
