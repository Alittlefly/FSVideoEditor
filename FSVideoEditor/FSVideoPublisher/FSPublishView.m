//
//  FSPublishView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSPublishView.h"

@implementation FSPublishView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        
        UIButton *fx = [[UIButton alloc] initWithFrame:CGRectMake(220, 100, 100, 100)];
        [fx setBackgroundColor:[UIColor redColor]];
        [fx addTarget:self action:@selector(clickFxButton:) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:fx];
    }
    return self;
}
-(void)clickFxButton:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(publishViewClickVideoFx:)]) {
        [self.delegate publishViewClickVideoFx:self];
    }
}
@end
