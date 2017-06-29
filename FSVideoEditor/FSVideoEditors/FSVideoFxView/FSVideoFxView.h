//
//  FSVideoFxView.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSVideoClipProgress.h"

@class FSVideoFxView;
@protocol FSVideoFxViewDelegate <NSObject>

-(void)videoFxViewSelectFx:(FSVideoFxView *)videoFxView PackageId:(NSString *)fxId startProgress:(CGFloat)startProgress endProgress:(CGFloat)endProgress;
-(void)videoFxViewSelectTimeFx:(FSVideoFxView *)videoFxView type:(FSVideoFxType)type duration:(int64_t)duration progress:(CGFloat)progress;
-(CGFloat)videoFxViewUpdateProgress:(FSVideoFxView *)videoFxView;
@optional
-(void)videoFxUndoPackageFx:(FSVideoFxView *)videoFxView;

-(void)videoFxSelectProgress:(FSVideoFxView *)videoFxView progress:(CGFloat)progress packageFxId:(NSString *)fxId;
@end

@interface FSVideoFxView : UIView

@property(nonatomic,assign)id<FSVideoFxViewDelegate>delegate;

@property(nonatomic,strong)UIView *progressBackView;
@property(nonatomic,assign)CGFloat duration;

@property(nonatomic,assign)BOOL needCovert;
// 特效
-(instancetype)initWithFrame:(CGRect)frame fxs:(NSArray *)fxs;

-(void)start;
-(void)stop;

-(void)hideUndoButton;
-(void)showUndoButton;
@end
