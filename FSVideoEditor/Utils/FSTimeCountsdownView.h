//
//  FSTimeCountdownView.h
//  7nujoom
//
//  Created by jiapeng on 16/6/7.
//  Copyright © 2016年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSTimeCountdownViewDelegate <NSObject>

-(void)timeCountViewCountToZero;

@end

@interface FSTimeCountsdownView : UIView

@property(nonatomic,assign)id<FSTimeCountdownViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame timeNumber:(int)timeNumber number:(NSInteger)number;
-(void)releaseTimer;
@end
