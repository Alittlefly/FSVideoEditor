//
//  FSVideoClipProgress.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoClipProgress.h"
#import "FSVideoEditorCommenData.h"
#import "FSPublishSingleton.h"


typedef NS_ENUM(NSInteger,FSProgressMoveType){
    FSProgressMoveTypeNone,
    FSProgressMoveTypeLine,
    FSProgressMoveTypeTint,
};
@interface FSVideoClipProgress()
{
    FSProgressMoveType _moveType;
    
    NSTimer *_fxTimer;
}
@property(nonatomic,strong)UIView *line;
@property(nonatomic,strong)UIView *backContent;
@property(nonatomic,strong)UIImageView *tintImage;
@property(nonatomic,strong)UIView *revertView;
@property(nonatomic,strong)UIView *fxView;
@property(nonatomic,strong)UIView *fxContent;
@end
@implementation FSVideoClipProgress
-(NSMutableArray *)renderRangeViews{
    if (!_renderRangeViews) {
        _renderRangeViews = [NSMutableArray array];
    }
    return _renderRangeViews;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _type = FSVideoFxTypeNone;
        _moveType = FSProgressMoveTypeNone;
        [self creatSubViews:frame];
    }
    return self;
}
-(void)creatSubViews:(CGRect)frame{
     _backContent = [[UIView alloc] initWithFrame:CGRectMake(0, 6.5, CGRectGetWidth(frame), CGRectGetHeight(frame) - 13)];
    [_backContent setUserInteractionEnabled:NO];
    [self addSubview:_backContent];
    
     _revertView = [[UIView alloc] initWithFrame:CGRectMake(0, 6.5, CGRectGetWidth(frame), CGRectGetHeight(frame) - 13)];
    [_revertView setUserInteractionEnabled:NO];
    [_revertView setBackgroundColor:FSHexRGBAlpha(0xff39ad,0.9)];
    [_revertView setHidden:YES];
    [self addSubview:_revertView];
    
     _fxContent = [[UIView alloc] initWithFrame:CGRectMake(0, 6.5, CGRectGetWidth(frame), CGRectGetHeight(frame) - 13)];
    [_fxContent setUserInteractionEnabled:NO];
    [self addSubview:_fxContent];
    
    
     _line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, CGRectGetHeight(frame))];
    [_line setBackgroundColor:FSHexRGB(0xFACE15)];
     _line.layer.cornerRadius = 2.5;
     _line.layer.masksToBounds = YES;
    [self addSubview:_line];
    
    _tintImage = [[UIImageView alloc] init];
    [_tintImage setAlpha:0.8];
    [_tintImage setFrame:CGRectMake(0, 0, 30, CGRectGetHeight(frame))];
    [_tintImage setUserInteractionEnabled:YES];
    [_tintImage setBackgroundColor:[UIColor redColor]];
    [_tintImage setHidden:YES];
    [self addSubview:_tintImage];
    

}
-(void)setBackGroundView:(UIView *)backGroundView{
    if (!backGroundView) {
        return;
    }
    [backGroundView setFrame:_backContent.bounds];
    [_backContent addSubview:backGroundView];
}
-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    [self updateLineFrame];
}
-(void)setNeedConvert:(BOOL)needConvert{
    _needConvert = needConvert;
}
-(void)setIsPlaying:(BOOL)isPlaying{
    _isPlaying = isPlaying;
    if (isPlaying && _ftype == FSFilterTypeTime) {
        [_line setBackgroundColor:FSHexRGBAlpha(0xFACE15,0.5)];
    }else{
        [_line setBackgroundColor:FSHexRGBAlpha(0xFACE15,1.0)];
    }
}
-(void)updateLineFrame{
    CGRect lFrame = _line.frame;
    CGFloat currentBe = _progress;
    lFrame.origin.x = currentBe * CGRectGetWidth(self.bounds);
    // 边界
    if (lFrame.origin.x < 0) {
        lFrame.origin.x = 0;
    }else if (lFrame.origin.x > CGRectGetWidth(self.bounds) - CGRectGetWidth(lFrame)){
        lFrame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(lFrame);
    }
    _line.frame = lFrame;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(_tintImage.frame, point) && !_tintImage.hidden) {
        _moveType = FSProgressMoveTypeTint;
    }
    else if (CGRectContainsPoint(CGRectMake(CGRectGetMinX(_line.frame) - 10, CGRectGetMinY(_line.frame) - 10, CGRectGetWidth(_line.frame) + 20, CGRectGetHeight(_line.frame)+20), point)) {
        if (_ftype == FSFilterTypeFx) {
            _moveType = FSProgressMoveTypeLine;
        }else{
            if(!_isPlaying){
                _moveType = FSProgressMoveTypeLine;
            }else{
                _moveType = FSProgressMoveTypeNone;
            }
        }
    }else{
        _moveType = FSProgressMoveTypeNone;
    }
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    if (_moveType == FSProgressMoveTypeTint) {
        CGRect tintFrame = _tintImage.frame;
        tintFrame.origin.x = point.x;
        _tintImage.frame = tintFrame;
    }
    else if (_moveType == FSProgressMoveTypeLine) {
        CGRect lineFrame = _line.frame;
        lineFrame.origin.x = point.x;
        _line.frame = lineFrame;
        _progress = point.x/self.bounds.size.width;
        // 需要反转
        
        CGFloat outProgress = _progress;
        if (_needConvert) {
            outProgress = 1 - _progress;
        }
        if ([self.delegate respondsToSelector:@selector(videoClipProgressSelectPoint:)]) {
            [self.delegate videoClipProgressSelectPoint:outProgress];
        }
    }
    [self resetBoundary];
}
-(void)resetBoundary{
    if (CGRectGetMaxX(_tintImage.frame) > CGRectGetWidth(self.bounds) - CGRectGetWidth(_tintImage.frame)) {
        CGRect tintFrame = _tintImage.frame;
        tintFrame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(_tintImage.frame);
        _tintImage.frame = tintFrame;
    }
    
    if (CGRectGetMinX(_tintImage.frame) < 0) {
        CGRect tintFrame = _tintImage.frame;
        tintFrame.origin.x = 0;
        _tintImage.frame = tintFrame;
    }
    
    if (CGRectGetMaxX(_line.frame) > CGRectGetWidth(self.bounds)-CGRectGetWidth(_line.frame)) {
        CGRect lineFrame = _line.frame;
        lineFrame.origin.x = CGRectGetWidth(self.bounds)-CGRectGetWidth(_line.frame);
        _line.frame = lineFrame;
    }
    
    if (CGRectGetMinX(_line.frame) < 0) {
        CGRect lineFrame = _line.frame;
        lineFrame.origin.x = 0;
        _line.frame = lineFrame;
    }
    
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    if (_moveType == FSProgressMoveTypeTint && _ftype != FSFilterTypeFx) {
        _selectProgress = CGRectGetMidX(_tintImage.frame)/CGRectGetWidth(self.bounds);
        
        [self setProgress:_selectProgress];
        
        if ([self.delegate respondsToSelector:@selector(videoClipProgressMoveSlideSelectPoint:)]) {
            [self.delegate videoClipProgressMoveSlideSelectPoint:_selectProgress];
        }
    }
    _moveType = FSProgressMoveTypeNone;
}
-(void)setSelectProgress:(CGFloat)selectProgress{
    _selectProgress = selectProgress;
    
    if (_ftype == FSFilterTypeTime && !_tintImage.hidden) {
        CGRect tintFrame = _tintImage.frame;
        tintFrame.origin.x = CGRectGetWidth(self.bounds) * selectProgress - CGRectGetWidth(tintFrame)/2.0;
        [_tintImage setFrame:tintFrame];
    }
}
-(void)setType:(FSVideoFxType)type{
    _type = type;
    if (type == FSVideoFxTypeSlow) {
        [_tintImage setImage:[UIImage imageNamed:@"slow"]];
    }else if (type == FSVideoFxTypeRepeat){
        [_tintImage setImage:[UIImage imageNamed:@"repeat"]];
    }else{
        [_tintImage setImage:nil];
    }
    [_tintImage setHidden:type == FSVideoFxTypeNone || type == FSVideoFxTypeRevert];
    [_revertView setHidden:type != FSVideoFxTypeRevert];
}
-(void)setFtype:(FSFilterType)ftype{
    _ftype = ftype;
    
    if (_ftype == FSFilterTypeFx) {
        [_tintImage setHidden:YES];
        [_revertView setHidden:YES];
        [_fxContent setHidden:NO];
    }else{
        [_fxContent setHidden:YES];
        [self setType:_type];
    }
}
#pragma mark - 
-(void)setVSpeed:(CGFloat)vSpeed{
    _vSpeed = vSpeed;
    
    
}
-(void)addFxView{
    
    CGFloat speed = self.vSpeed; //CGRectGetWidth(self.bounds) * 0.1/10;//MAX(1.0) ;
    if (_progress <= 1.0) {
        if (!_fxView) {
            CGFloat startProgress = _progress;
             _fxView = [[UIView alloc] initWithFrame:CGRectMake(startProgress * self.bounds.size.width, 0, speed, CGRectGetHeight(self.bounds) - 13)];
             _fxView.backgroundColor = _fxViewColor;
            [_fxContent addSubview:_fxView];
        }
        else {
            if (_needConvert) {
                CGRect fxFrame = self.fxView.frame;
                fxFrame.origin.x -= speed;
                fxFrame.size.width += speed;
                self.fxView.frame = fxFrame;
            }else{
                CGRect fxFrame = self.fxView.frame;
                fxFrame.size.width += speed;
                self.fxView.frame = fxFrame;
            }
        }
        
        
        if (_needConvert) {
             _progress = MIN(1, MAX(CGRectGetMinX(self.fxView.frame)/self.bounds.size.width, 0));
        }else{
             _progress = MIN(1, MAX(CGRectGetMaxX(self.fxView.frame)/self.bounds.size. width, 0));
        }
        
        [self updateLineFrame];
        
        
        CGFloat outProgress = _needConvert?(1-_progress):_progress;
        if(outProgress == 1.0){
            [_fxTimer setFireDate:[NSDate distantFuture]];
            
            if ([self.delegate respondsToSelector:@selector(videoClipProgressStartSelect:)]) {
                [self.delegate videoClipProgressSelectPoint:outProgress];
            }
            
            return;
        }
    }
}
#pragma mark -
-(void)beginFxView{
    CGFloat outProgress = _needConvert?(1-_progress):_progress;
    if(outProgress == 1.0){
        [self endFxView:NO];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(videoClipProgressStartSelect:)]) {
        [self.delegate videoClipProgressStartSelect:MIN(1, MAX(outProgress, 0))];
    }
    
    if (!_fxTimer) {
         _fxTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(addFxView) userInfo:nil repeats:YES];
    }
    [_fxTimer setFireDate:[NSDate distantPast]];
}
-(void)endFxView:(BOOL)notice{
    [_fxTimer setFireDate:[NSDate distantFuture]];
    
    UIView *aView = self.fxView;
    if (aView) {
        [self.renderRangeViews addObject:aView];
    }
    
    _fxView = nil;
    
    if (notice) {
        CGFloat outProgress = _needConvert?(1-_progress):_progress;
        
        if ([self.delegate respondsToSelector:@selector(videoClipProgressEndSelect:)]) {
            [self.delegate videoClipProgressEndSelect:MIN(1, MAX(outProgress, 0))];
        }
    }
}
-(void)undoFxView{
    UIView *fxView = [self.renderRangeViews lastObject];
    
    CGFloat willBePoint = !_needConvert?CGRectGetMinX(fxView.frame):CGRectGetMaxX(fxView.frame);
    
    CGFloat progress = willBePoint/CGRectGetWidth(self.bounds);
    [self setProgress:progress>1.0 ? 1.0:progress];
    
    if ([self.delegate respondsToSelector:@selector(videoClipProgressSelectPoint:)]) {
        [self.delegate videoClipProgressSelectPoint:!_needConvert?progress:(1-progress)];
    }
    
    [fxView removeFromSuperview];
    [self.renderRangeViews removeLastObject];
    fxView = nil;
}

-(void)addFitteredView:(NSArray *)fiterdViews{
    
    [self.renderRangeViews addObjectsFromArray:fiterdViews];
    
    for (UIView *view in fiterdViews) {
        [_fxContent addSubview:view];
    }
}
-(void)setTintPosition:(CGFloat)postion{
    CGFloat centerX = postion * CGRectGetWidth(self.bounds);
    CGPoint tintCenter = self.tintImage.center;
    tintCenter.x = centerX;
    self.tintImage.center = tintCenter;
}

-(void)dealloc{
    NSLog(@"%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
-(NSInteger)fiterCout{
    return [self.renderRangeViews count];
}
@end
