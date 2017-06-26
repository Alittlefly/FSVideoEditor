//
//  FSThumbnailView.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,SliderType){
    SliderTypeNone,
    SliderTypeLeftSlider,
    SliderTypeRightSlider
};
@protocol FSThumbnailViewDelegate <NSObject>
-(void)thumbnailViewSelectValue:(double)value type:(SliderType)type;

@optional
-(void)thumbnailViewSelectStartValue:(double)startValue endValue:(double)endvalue;

-(void)thumbnailViewEndSelect;
@end

@interface FSThumbnailView : UIView

@property(nonatomic,assign)id<FSThumbnailViewDelegate>delegate;
// 自身长度
@property(nonatomic,assign)double length;
//  总共长度
@property(nonatomic,assign)double allLength;
// default 0
@property(nonatomic,assign)double minLength;

@property(nonatomic,strong)UIView *backGroundView;

-(instancetype)initWithFrame:(CGRect)frame length:(double)length allLength:(double)allLength minLength:(double)minLength;
@end
