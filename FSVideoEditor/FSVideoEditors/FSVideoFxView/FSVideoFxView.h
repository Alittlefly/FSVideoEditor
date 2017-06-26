//
//  FSVideoFxView.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSVideoClipProgress.h"


@protocol FSVideoFxViewDelegate <NSObject>
-(void)videoFxViewSelectFxPackageId:(NSString *)fxId;
-(void)videoFxViewSelectTimeFx:(FSVideoFxType)type;
-(CGFloat)videoFxViewUpdateProgress;
@end

@interface FSVideoFxView : UIView

@property(nonatomic,assign)id<FSVideoFxViewDelegate>delegate;

@property(nonatomic,strong)UIView *progressBackView;
@property(nonatomic,assign)CGFloat duration;
// 特效
-(instancetype)initWithFrame:(CGRect)frame fxs:(NSArray *)fxs;

-(void)start;
-(void)stop;
@end
