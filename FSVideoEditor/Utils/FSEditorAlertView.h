//
//  FSEditorAlertView.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSEditorAlertView : UIView

@property(nonatomic,strong)NSString *text;

-(void)show;
-(void)hide;
@end
