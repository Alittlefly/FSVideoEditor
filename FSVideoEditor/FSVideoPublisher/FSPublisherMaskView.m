//
//  FSPublisherMaskView.m
//  FSVideoEditor
//
//  Created by gongruike on 2017/9/7.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSPublisherMaskView.h"
#import "FSVideoEditorCommenData.h"

@implementation FSPublisherMaskView

- (instancetype)init {
    if (self = [super init]) {
        [self.layer addSublayer:self.topLayer];
        [self.layer addSublayer:self.bottomLayer];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

- (CAGradientLayer *)topLayer {
    if (!_topLayer) {
        _topLayer = [CAGradientLayer layer];
        _topLayer.startPoint = CGPointMake(0, 0.0);
        _topLayer.endPoint = CGPointMake(0, 1.0);
        _topLayer.colors = @[(__bridge id)FSHexRGBAlpha(0x000000, 0.3).CGColor,
                             (__bridge id)FSHexRGBAlpha(0xffffff, 0.0).CGColor];
    }
    return _topLayer;
}

- (CAGradientLayer *)bottomLayer {
    if (!_bottomLayer) {
        _bottomLayer = [CAGradientLayer layer];
        _bottomLayer.startPoint = CGPointMake(0, 0.0);
        _bottomLayer.endPoint = CGPointMake(0, 1.0);
        _bottomLayer.colors = @[(__bridge id)FSHexRGBAlpha(0xffffff, 1.0).CGColor,
                                (__bridge id)FSHexRGBAlpha(0x000000, 1.0).CGColor];
    }
    return _bottomLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.topLayer setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 110)];
    [self.bottomLayer setFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 207, CGRectGetWidth(self.bounds), 207)];
}

@end
