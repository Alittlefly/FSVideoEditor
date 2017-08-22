//
//  FSDraftEmptyView.m
//  FSVideoEditor
//
//  Created by stu on 2017/8/22.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftEmptyView.h"
#import "FSVideoEditorCommenData.h"


@implementation FSDraftEmptyView

-(UIImageView *)imageIcon{
    if (!_imageIcon) {
        _imageIcon = [[UIImageView alloc] init];
        [self addSubview:_imageIcon];
    }
    return _imageIcon;
}

-(UILabel *)message{
    if (!_message) {
        _message = [[UILabel alloc] init];
        [_message setFont:[UIFont systemFontOfSize:13]];
        [_message setTextColor:FSHexRGB(0x999999)];
        [_message setTextAlignment:NSTextAlignmentCenter];
        [_message setNumberOfLines:0];
        [self addSubview:_message];
    }
    return _message;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    [self.imageIcon setFrame:CGRectMake((CGRectGetWidth(self.bounds) - 110)/2, 81, 110, 110)];
    [self.message setFrame:CGRectMake(60, CGRectGetMaxY(self.imageIcon.frame) + 30, CGRectGetWidth(self.bounds) - 120, 36)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
