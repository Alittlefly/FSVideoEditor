//
//  FSVideoClipProgress.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoClipProgress.h"

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
@property(nonatomic,strong)NSMutableArray *renderRangeViews;
@property(nonatomic,strong)UIView *fxView;
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
    _progress = (_type != FSVideoFxTypeRevert)?progress:(1-progress);
    
    [self updateLineFrame];
}
-(void)updateLineFrame{
    CGRect lFrame = _line.frame;
    lFrame.origin.x = _progress * CGRectGetWidth(self.bounds);
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
    else if (CGRectContainsPoint(_line.frame, point)) {
        _moveType = FSProgressMoveTypeLine;
    }
    else{
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
        if ([self.delegate respondsToSelector:@selector(FSVideoClipProgressUpdateProgress:)]) {
            [self.delegate FSVideoClipProgressUpdateProgress:_progress];
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
    
    if (_moveType == FSProgressMoveTypeTint) {
        self.selectProgress = CGRectGetMidX(_tintImage.frame)/CGRectGetWidth(self.bounds);
    }
    _moveType = FSProgressMoveTypeNone;
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
    }else{
        [self setType:_type];
    }
}
#pragma mark - 
-(void)addFxView{
    if (!_fxView) {
        _fxView = [[UIView alloc] initWithFrame:CGRectMake(_progress*self.bounds.size.width, 0, self.bounds.size.width*0.1/10, self.bounds.size.height)];
        _fxView.backgroundColor = [UIColor redColor];
        [self addSubview:_fxView];
    }
    else {
        CGRect fxFrame = self.fxView.frame;
        fxFrame.size.width += self.bounds.size.width*0.1/10;
        self.fxView.frame = fxFrame;
    }
    
    _progress = (self.fxView.frame.size.width+self.fxView.frame.origin.x)/self.bounds.size.width;
    [self updateLineFrame];
}
#pragma mark -
-(void)beginFxView{
//    if (!_fxTimer) {
//        _fxTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(addFxView) userInfo:nil repeats:YES];
//    }
//    [_fxTimer setFireDate:[NSDate distantPast]];
}
-(void)endFxView{
    [_fxTimer setFireDate:[NSDate distantFuture]];
    
    UIView *aView = self.fxView;
    [self.renderRangeViews addObject:aView];
    _fxView = nil;
}
-(void)undoFxView{
    UIView *fxView = [self.renderRangeViews lastObject];
    [fxView removeFromSuperview];
    [self.renderRangeViews removeLastObject];
    fxView = nil;
}
-(void)dealloc{
    NSLog(@"%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
@end
