//
//  FSVideoClipProgress.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct{
    CGFloat startValue;
    CGFloat endValue;
}ProgressRange;

typedef NS_ENUM(NSInteger,FSFilterType){
    FSFilterTypeFx,
    FSFilterTypeTime,
};

typedef NS_ENUM(NSInteger,FSVideoFxType){
    FSVideoFxTypeNone,
    FSVideoFxTypeRevert,
    FSVideoFxTypeSlow,
    FSVideoFxTypeRepeat,
};

@protocol FSVideoClipProgressDelegate <NSObject>

- (void)FSVideoClipProgressUpdateProgress:(CGFloat)progress;

- (void)videoClipProgressEndSelect:(CGFloat)progress;

- (void)videoClipProgressUndoState:(BOOL)shouldShow;

@end


@interface FSVideoClipProgress : UIView
@property(nonatomic,assign)CGFloat progress;
@property(nonatomic,assign)CGFloat selectProgress;
@property(nonatomic,assign,readonly)ProgressRange valueRange;
@property(nonatomic,strong)UIView *backGroundView;
@property(nonatomic,assign)FSVideoFxType type;
@property(nonatomic,assign)FSFilterType ftype;
@property(nonatomic,assign)BOOL needConvert;

@property(nonatomic,weak) id<FSVideoClipProgressDelegate> delegate;

@property(nonatomic,strong)UIColor *fxViewColor;
@property(nonatomic,strong)NSMutableArray *renderRangeViews;

@property(nonatomic,assign,readonly)NSInteger fiterCout;



-(void)beginFxView;
-(void)endFxView;

-(void)undoFxView;

-(void)addFitteredView:(NSArray *)fiterdViews;
@end
