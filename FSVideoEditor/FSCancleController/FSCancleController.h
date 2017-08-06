//
//  FSCancleController.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/14.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSCancleController : UIViewController

@property(nonatomic,strong)UIButton *cancleButton;

-(void)initCancleButton;
- (void)dissmissController;
@end
