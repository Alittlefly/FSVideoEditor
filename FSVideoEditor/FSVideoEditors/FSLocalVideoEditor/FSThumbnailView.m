//
//  FSThumbnailView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSThumbnailView.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"

@interface FSThumbnailView()<UIScrollViewDelegate>
{
    SliderType _sliderType;
    
    double _startValue;
    double _endValue;
    
    CGPoint _startPoint;
    BOOL _collide;
    NSInteger _touchBegin;
    double _startOffSet;
    
    CGFloat _minWidth;
    CGFloat _maxWidth;
}
@property(nonatomic,strong)UIView *contentBorder;
@property(nonatomic,strong)UIImageView *leftSlide;
@property(nonatomic,strong)UIImageView *rightSlide;
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
        _endValue = MIN(_allLength, _length);
        _startOffSet = 0;
        
        _collide = NO;

        _startOffSet = 0;
        
        
        if (_length != 0) {
            _minWidth = _minLength/_length * (CGRectGetWidth(frame) - 60);
            _maxWidth = MAX(_minLength/_length, MIN(_allLength/_length, 1)) *(CGRectGetWidth(frame) - 60);
        }
        [self creatSubviews:frame];
        [self setClipsToBounds:NO];
        
        
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
    CGFloat padding = 30;
     _backContentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    [_backContentView setBackgroundColor:FSHexRGBAlpha(0x000000, 0.4)];
    [_backContentView setDelegate:self];
    [_backContentView setClipsToBounds:NO];
    [_backContentView setShowsHorizontalScrollIndicator:NO];
    [self addSubview:_backContentView];
    
    _contentBorder = [[UIView alloc] initWithFrame:CGRectMake(padding, 0, CGRectGetWidth(frame) - padding * 2, CGRectGetHeight(frame))];
    _contentBorder.layer.borderColor = FSHexRGB(0xF9CC35).CGColor;
    _contentBorder.layer.borderWidth = 2.0;
    _contentBorder.userInteractionEnabled = NO;
    [self addSubview:_contentBorder];
    
     _leftSlide = [[UIImageView alloc] initWithFrame:CGRectMake(padding - 15, 0, 15, CGRectGetHeight(frame))];
    [_leftSlide setImage:[UIImage imageNamed:@"videoSelectSlider"]];
    [_leftSlide setUserInteractionEnabled:YES];
    [self addSubview:_leftSlide];
    
     _rightSlide = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - padding,0,15, CGRectGetHeight(frame))];
    [_rightSlide setImage:[UIImage imageNamed:@"videoSelectSlider"]];
    [_rightSlide setUserInteractionEnabled:YES];
    [self addSubview:_rightSlide];
    
     _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -31, CGRectGetWidth(frame), 16.0)];
    [_tipLabel setFont:[UIFont systemFontOfSize:11.0]];
    [_tipLabel setTextColor:FSHexRGB(0xffffff)];
    [_tipLabel setTextAlignment:(NSTextAlignmentCenter)];
    
    [self updateTipText];
    [self addSubview:_tipLabel];

    // 重置边界
    [self resetBoundry:(SliderTypeRightSlider)];
    // 绘制border
    [self updateContentBorder];
}

-(void)setBackGroundView:(UIView *)backGroundView{
    if (!backGroundView) {
        return;
    }
    _backGroundView = backGroundView;
    
    CGFloat width = _allLength/_length * CGRectGetWidth(_backContentView.frame);
     backGroundView.frame = CGRectMake(0, 0,width, CGRectGetHeight(self.bounds));
    [_backContentView setContentSize:CGSizeMake(width, 0)];
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
    
    [self updateTipText];
}
-(void)updateNvsStreamContent{
    
    _endValue = _startOffSet + (CGRectGetMinX(_rightSlide.frame) - 30)/CGRectGetWidth(_backContentView.frame)  *_length;
    _startValue = _startOffSet + (CGRectGetMaxX(_leftSlide.frame) - 30)/CGRectGetWidth(_backContentView.frame) *_length;
    
    NSLog(@"_startValue %f _endValue %f",_startValue,_endValue);
    
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
        if (CGRectGetMinX(_leftSlide.frame) < 15) {
            CGRect lframe = _leftSlide.frame;
            lframe.origin.x = 15;
            _leftSlide.frame = lframe;
        }
    }else if(type == SliderTypeRightSlider){
        
        CGFloat maxX = MAX(_minLength/_length, MIN(_allLength/_length, 1)) * (CGRectGetWidth(self.bounds) - 60) + CGRectGetMinX(_backContentView.frame);
        
        if (CGRectGetMaxX(_rightSlide.frame) > maxX) {
            CGRect rframe = _rightSlide.frame;
            rframe.origin.x = maxX ;
            _rightSlide.frame = rframe;
        }
    }
    
    // 重叠或者交换位置
    if (_collide && _sliderType != SliderTypeNone) {
        if (_sliderType == SliderTypeRightSlider) {
            // 修正右边
            CGRect rFrame = _rightSlide.frame;
            rFrame.origin.x = CGRectGetMaxX(_leftSlide.frame) + _minWidth;
            _rightSlide.frame = rFrame;
        }else{
            // 修正左边
            CGRect lFrame = _leftSlide.frame;
            lFrame.origin.x = CGRectGetMinX(_rightSlide.frame) - _minWidth - CGRectGetWidth(_leftSlide.frame);
            _leftSlide.frame = lFrame;
        }
    }
}
-(BOOL)isCollide:(SliderType)type{
    
    if (type == SliderTypeNone) {
        return NO;
    }
    
    CGFloat currentGap = CGRectGetMinX(_rightSlide.frame) - CGRectGetMaxX(_leftSlide.frame);
    if (currentGap < _minWidth) {
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
#pragma mark - 
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    NSLog(@" scrollViewDidEndDragging contentOffSet %f",scrollView.contentOffset.x);
    
    CGFloat offSetx = scrollView.contentOffset.x;
    if (offSetx < 0) {
        return;
    }
    
    _startOffSet = offSetx/scrollView.contentSize.width;
    _startValue = _startOffSet + (CGRectGetMaxX(_leftSlide.frame) - 30)/CGRectGetWidth(_backContentView.frame) *_length;
    _endValue = _startOffSet + (CGRectGetMinX(_rightSlide.frame) - 30)/CGRectGetWidth(_backContentView.frame) *_length;
    
    if ([self.delegate respondsToSelector:@selector(thumbnailViewSelectStartValue:endValue:)]) {
        [self.delegate thumbnailViewSelectStartValue:_startValue endValue:_endValue];
    }
    
    [self updateTipText];
    
    if ([self.delegate respondsToSelector:@selector(thumbnailViewEndSelect)]) {
        [self.delegate thumbnailViewEndSelect];
    }
}

-(void)updateTipText{
    double timeLength = _endValue - _startValue;
    BOOL shouldBeRed = (timeLength == _minLength) || (timeLength == _length) || (timeLength == _allLength);
    
    NSString *time = [NSString stringWithFormat:@"%.2f",timeLength];
    NSString *orginalText = [FSShortLanguage CustomLocalizedStringFromTable:@"ChoseVideoTime"];//NSLocalizedString(@"ChoseVideoTime", nil);
    NSString *finalSting = [orginalText stringByReplacingOccurrencesOfString:@"(0)" withString:time];
    
    NSDictionary *timeAttrRed = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor redColor],NSForegroundColorAttributeName,nil];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:finalSting];
    
    if (shouldBeRed) {
        NSRange range = [finalSting rangeOfString:time];
        if(range.location != NSNotFound)
            [attrString addAttributes:timeAttrRed range:range];
    }

    [_tipLabel setAttributedText:attrString];
}

-(void)dealloc{
    NSLog(@"%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
@end
