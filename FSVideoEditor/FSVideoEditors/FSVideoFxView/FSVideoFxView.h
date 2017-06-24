//
//  FSVideoFxView.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,FSVideoFxType){
    FSVideoFxTypeNone,
    FSVideoFxTypeRevert,
    FSVideoFxTypeSlow,
    FSVideoFxTypeRepeat,
};

@protocol FSVideoFxViewDelegate <NSObject>
-(void)videoFxViewSelectFxPackageId:(NSString *)fxId;
-(void)videoFxViewSelectTimeFx:(FSVideoFxType)type;
@end

@interface FSVideoFxView : UIView

@property(nonatomic,assign)id<FSVideoFxViewDelegate>delegate;

@property(nonatomic,strong)UIView *progressBackView;
// 特效
-(instancetype)initWithFrame:(CGRect)frame fxs:(NSArray *)fxs;
@end
