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

typedef NS_ENUM(NSInteger,FSVideoFxType){
    FSVideoFxTypeNone,
    FSVideoFxTypeRevert,
    FSVideoFxTypeSlow,
    FSVideoFxTypeRepeat,
};

@interface FSVideoClipProgress : UIView
@property(nonatomic,assign)CGFloat progress;
@property(nonatomic,assign)CGFloat selectProgress;
@property(nonatomic,assign,readonly)ProgressRange valueRange;
@property(nonatomic,strong)UIView *backGroundView;
@property(nonatomic,assign)FSVideoFxType type;
@end
