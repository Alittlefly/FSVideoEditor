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
@property (nonatomic, strong) NSMutableArray *linesArray;

@end

@implementation FSProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        _progressView.backgroundColor = [UIColor redColor];
        [self addSubview:_progressView];
        
        _linesArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)setProgressViewColor:(UIColor *)progressViewColor {
    self.progressView.backgroundColor = progressViewColor;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)isAnimated {
    CGFloat width = progress * self.bounds.size.width;
    //CGFloat oldW = self.progressView.frame.size.width;

    if (isAnimated) {
        [UIView animateWithDuration:0.1 animations:^{
            self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, width, self.progressView.frame.size.height);
        }];
    }
    else {
        self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, width, self.progressView.frame.size.height);
    }
}

- (void)stopAnimationWithCuttingLine {
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.progressView.frame.size.width, 0, 2, self.frame.size.height)];
    line.backgroundColor = [UIColor whiteColor];
    [self addSubview:line];
    
    [_linesArray addObject:line];
}

- (void)deleteCuttingLine {
    if (_linesArray.count == 0) {
        return;
    }
    UIView *line = [_linesArray lastObject];
    [line removeFromSuperview];
    [_linesArray removeLastObject];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
