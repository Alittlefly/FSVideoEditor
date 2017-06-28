//
//  FSSegmentView.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/28.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSSegmentView;

@protocol FSSegmentViewDelegate <NSObject>

- (void)FSSegmentView:(FSSegmentView *)segmentView selected:(NSInteger)index;

@end

@interface FSSegmentView : UIView

@property (nonatomic, weak) id<FSSegmentViewDelegate> delegate;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *unSelectedTextColor;
@property (nonatomic, assign) NSInteger selectedSegmentIndex;

- (instancetype)initWithItems:(NSArray *)itmes;

@end
