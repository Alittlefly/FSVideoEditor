//
//  FSProgressView.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/23.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSProgressView.h"

@interface FSProgressView()

@property (nonatomic, strong) UIView *progressView;

@end

@implementation FSProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        _progressView.backgroundColor = [UIColor redColor];
        [self addSubview:_progressView];
        
    }
    return self;
}

- (void)setProgressViewColor:(UIColor *)progressViewColor {
    self.progressView.backgroundColor = progressViewColor;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)isAnimated {
    CGFloat width = progress * self.bounds.size.width;

    if (isAnimated) {
        [UIView animateWithDuration:0.5*(width-self.progressView.frame.size.width) animations:^{
            self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, width, self.progressView.frame.size.height);
        }];
    }
    else {
        self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, width, self.progressView.frame.size.height);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
