//
//  FSThumbnailView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSThumbnailView.h"


@interface FSThumbnailView()
{
    CGFloat _sliderGap;
    SliderType _sliderType;
    double _startValue;
    double _endValue;
    CGPoint _startPoint;
    BOOL _collide;
    NSInteger _touchBegin;
    double _startOffSet;
}
@property(nonatomic,strong)UIView *contentBorder;
@property(nonatomic,strong)UIView *leftSlide;
@property(nonatomic,strong)UIView *rightSlide;
@property(nonatomic,strong)UIScrollView *backContentView;
@property(nonatomic,strong)UILabel *tipLabel;
@end

@implementation FSThumbnailView
-(instancetype)initWithFrame:(CGRect)frame length:(double)length allLength:(double)allLength minLength:(double)minLength{
    if (self  = [super initWithFrame:frame]) {
        _length = length;
        _allLength = allLength;
        _minLength = minLength;
        
        _sliderType = SliderTypeNone;
        _startValue = 0;
        _endValue = _length;
        _startOffSet = 0;
        
        _collide = NO;
        _sliderGap = _minLength/_length * CGRectGetWidth(frame);
        _startOffSet = 0;
        
        [self creatSubviews:frame];
        [self setClipsToBounds:NO];
  
        [self setBackgroundColor:[UIColor redColor]];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self creatSubviews:frame];
        [self setClipsToBounds:NO];
        _sliderType = SliderTypeNone;
        _startValue = 0;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}
-(void)creatSubviews:(CGRect)frame{
    _backContentView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(frame) - 40, CGRectGetHeight(frame))];
    [_backContentView setBackgroundColor:[UIColor blueColor]];
    [self addSubview:_backContentView];
    
    _contentBorder = [[UIView alloc] initWithFrame:CGRectMake(40, 0, CGRectGetWidth(frame) - 80, CGRectGetHeight(frame))];
    _contentBorder.layer.borderColor = [UIColor redColor].CGColor;
    _contentBorder.layer.borderWidth = 2.0;
    _contentBorder.userInteractionEnabled = NO;
    [self addSubview:_contentBorder];
    
     _leftSlide = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 20, CGRectGetHeight(frame))];
    [_leftSlide setBackgroundColor:[UIColor redColor]];
    [self addSubview:_leftSlide];
    
     _rightSlide = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 40,0, 20, CGRectGetHeight(frame))];
    [_rightSlide setBackgroundColor:[UIColor blueColor]];
    [self addSubview:_rightSlide];
    
     _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -31, CGRectGetWidth(frame), 16.0)];
    [_tipLabel setFont:[UIFont systemFontOfSize:11.0]];
    [_tipLabel setTextColor:FSHexRGB(0xffffff)];
    [_tipLabel setTextAlignment:(NSTextAlignmentCenter)];
    [_tipLabel setText:@"已选取15s"];
    [self addSubview:_tipLabel];

    // 重置边界
    [self updateContentBorder];
}

-(void)setBackGroundView:(UIView *)backGroundView{
    if (!backGroundView) {
        return;
    }
    _backGroundView = backGroundView;
     backGroundView.frame = CGRectMake(0, 0,CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [_backContentView addSubview:backGroundView];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = touches.anyObject;
    CGPoint tpoint = [touch locationInView:self];
    
    if (CGRectContainsPoint(_leftSlide.frame, tpoint)) {
        _sliderType = SliderTypeLeftSlider;
        
    }else if (CGRectContainsPoint(_rightSlide.frame, tpoint)){
        _sliderType = SliderTypeRightSlider;
    }else{
        _sliderType = SliderTypeNone;
    }
    
    if (_sliderType != SliderTypeNone) {
        _startPoint = tpoint;
    }
    
    [_backContentView setUserInteractionEnabled:(_sliderType == SliderTypeNone)];
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    // 俩个块挨着了
    if (_collide) {
        // 左边的只能向左 右边的只能向右
        BOOL moveToLeft = (point.x - _startPoint.x) < 0;
        if ((moveToLeft && _sliderType == SliderTypeRightSlider) || (!moveToLeft && _sliderType == SliderTypeLeftSlider)) {
            // 滑动到边界了
            return;
        }
    }
    //  滑动
    [self moveSlider:_sliderType toPoint:point];
    //
    [self updateContentBorder];
    
    [self updateNvsStreamContent];
}
-(void)updateNvsStreamContent{
    
    if ([self.delegate respondsToSelector:@selector(thumbnailViewSelectValue:type:)]) {
        double value = 0;
        if (_sliderType == SliderTypeRightSlider) {
            value = _endValue;
        }else if (_sliderType == SliderTypeLeftSlider){
            value = _startValue;
        }
        [self.delegate thumbnailViewSelectValue:value type:_sliderType];
    }
}
-(void)moveSlider:(SliderType)type toPoint:(CGPoint)topoint{

    CGRect mFrame;
    if (type == SliderTypeLeftSlider) {
        mFrame = _leftSlide.frame;
        mFrame.origin.x = topoint.x;
        _leftSlide.frame = mFrame;
    }else if (type == SliderTypeRightSlider){
        mFrame = _rightSlide.frame;
        mFrame.origin.x = topoint.x;
        _rightSlide.frame = mFrame;
    }
    
    _collide = [self isCollide:type];

    [self resetBoundry:type];
    
    _endValue = _startOffSet + CGRectGetMinX(_rightSlide.frame)/CGRectGetWidth(_backContentView.frame)  *_length;
    _startValue = _startOffSet + CGRectGetMaxX(_leftSlide.frame)/CGRectGetWidth(_backContentView.frame) *_length;
}
-(void)updateContentBorder{
    CGFloat startx = CGRectGetMaxX(_leftSlide.frame);
    CGFloat endx = CGRectGetMinX(_rightSlide.frame);
    CGFloat width = endx - startx;
    CGFloat height = CGRectGetHeight(self.bounds);
    [_contentBorder setFrame:CGRectMake(startx, 0, width, height)];
}
-(void)resetBoundry:(SliderType)type{
    
    //
    if (type == SliderTypeLeftSlider) {
        if (CGRectGetMinX(_leftSlide.frame) <= -1) {
            CGRect lframe = _leftSlide.frame;
            lframe.origin.x = 0;
            _leftSlide.frame = lframe;
        }
    }else if(type == SliderTypeRightSlider){
        if (CGRectGetMaxX(_rightSlide.frame) >= CGRectGetWidth(self.bounds) - 39) {
            CGRect rframe = _rightSlide.frame;
            rframe.origin.x = CGRectGetWidth(self.bounds) - 40;
            _rightSlide.frame = rframe;
        }
    }
    
    // 重叠或者交换位置
    if (_collide && _sliderType != SliderTypeNone) {
        if (_sliderType == SliderTypeRightSlider) {
            // 修正右边
            CGRect rFrame = _rightSlide.frame;
            rFrame.origin.x = CGRectGetMaxX(_leftSlide.frame) + _sliderGap;
            _rightSlide.frame = rFrame;
        }else{
            // 修正左边
            CGRect lFrame = _leftSlide.frame;
            lFrame.origin.x = CGRectGetMinX(_rightSlide.frame) - CGRectGetWidth(_leftSlide.frame) - _sliderGap;
            _leftSlide.frame = lFrame;
        }
    }
}
-(BOOL)isCollide:(SliderType)type{
    
    if (type == SliderTypeNone) {
        return NO;
    }
    
    CGFloat currentGap = CGRectGetMinX(_rightSlide.frame) - CGRectGetMaxX(_leftSlide.frame);
    if (currentGap <= _sliderGap) {
        return YES;
    }
    
    return NO;
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    [_backContentView setUserInteractionEnabled:YES];
    
    if (_sliderType != SliderTypeNone) {
        if ([self.delegate respondsToSelector:@selector(thumbnailViewEndSelect)]) {
            [self.delegate thumbnailViewEndSelect];
        }
    }
    _sliderType = SliderTypeNone;
}
@end
