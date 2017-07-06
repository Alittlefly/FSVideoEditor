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

// 保存反转
-(void)videoFxViewNeedConvertView:(BOOL)convert type:(FSVideoFxType)type;

//  添加时间特效
-(void)videoFxViewSelectTimeFx:(FSVideoFxView *)videoFxView type:(FSVideoFxType)type duration:(int64_t)duration progress:(CGFloat)progress;
//  根据当前的时间轨跟新位置
-(CGFloat)videoFxViewUpdatePosition:(FSVideoFxView *)videoFxView;
@optional

//  撤销
-(void)videoFxUndoPackageFx:(FSVideoFxView *)videoFxView;
//  选择时间点
-(void)videoFxSelectTimeLinePosition:(FSVideoFxView *)videoFxView position:(CGFloat)progress shouldPlay:(BOOL)play;

// 添加特效方法
-(void)videoFxSelectStart:(FSVideoFxView *)videoFxView progress:(CGFloat)progress packageFxId:(NSString *)fxId;
-(void)videoFxSelectEnd:(FSVideoFxView *)videoFxView progress:(CGFloat)progress packageFxId:(NSString *)fxId;
//
@end

@interface FSVideoFxView : UIView

@property(nonatomic,assign)id<FSVideoFxViewDelegate>delegate;

@property(nonatomic,strong)UIView *progressBackView;
@property(nonatomic,assign)CGFloat duration;

@property(nonatomic,assign)BOOL needCovert;
@property(nonatomic,assign)FSVideoFxType fxType;
@property(nonatomic,strong)NSArray *addedViews;
@property(nonatomic,assign)CGFloat tintPositon;
-(void)addFiltterViews:(NSArray *)filterViews;
// 特效
-(instancetype)initWithFrame:(CGRect)frame fxs:(NSArray *)fxs;

// 修改光标位置
-(void)startMoveTint;
// 停止修改光标位置
-(void)stopMoveTint;

-(void)hideUndoButton;
-(void)showUndoButton;
@end
