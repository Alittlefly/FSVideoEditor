//
//  FSVideoFxView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoFxView.h"
#import <objc/runtime.h>

#define FxButtonH 50.0
#define FxButtonP 30.0


@interface FSFxLongPressButton : UIView
{
    __weak id _target;
    SEL _sel;
}
@property(nonatomic,strong)UIImageView *colorView;
@property(nonatomic,strong)UILabel *titleLabel;
-(void)addTarget:(id)target longPressAction:(SEL)selector;
@end

@implementation FSFxLongPressButton

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setClipsToBounds:NO];
        _titleLabel = [[UILabel alloc] initWithFrame:[self titleRectForContentRect:self.bounds]];
        [self addSubview:_titleLabel];
        [_titleLabel setTextColor:FSHexRGB(0xf5f5f5)];
        [_titleLabel setFont:[UIFont systemFontOfSize:11.0]];
        [_titleLabel setTextAlignment:(NSTextAlignmentCenter)];
        
         _colorView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_colorView.layer setCornerRadius:CGRectGetHeight(frame)/2.0];
        [_colorView.layer setMasksToBounds:YES];
        [_colorView setUserInteractionEnabled:NO];
        [self addSubview:_colorView];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(longPressHandler:)];
        [self addGestureRecognizer:longPress];
    }
    return self;
}
-(void)addTarget:(id)target longPressAction:(SEL)selector{
    _target = target;
    _sel = selector;
}

-(void)longPressHandler:(UILongPressGestureRecognizer *)recognizer{
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"UIGestureRecognizerStateEnded");
    }else{
    
    }
    
//    if (_target && _sel && [_target respondsToSelector:_sel]) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//        [_target performSelector:_sel withObject:self];
//#pragma clang diagnostic pop
//    }
}


-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [_colorView setBackgroundColor:backgroundColor];
}
-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    return self.bounds;
}
-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGRect titleRect;
    titleRect.size.width = CGRectGetWidth(contentRect);
    titleRect.size.height = 16.0;
    titleRect.origin.x = 0;
    titleRect.origin.y = CGRectGetHeight(contentRect) + 11.0;
    return titleRect;
}

@end

@interface FSFxButton : UIButton
@property(nonatomic,strong)UIView *colorView;
@end
@implementation FSFxButton
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setClipsToBounds:NO];
        [self.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
        [self.titleLabel setTextAlignment:(NSTextAlignmentCenter)];
        [self setTitleColor:FSHexRGB(0xf5f5f5) forState:(UIControlStateNormal)];
        
         _colorView = [[UIView alloc] initWithFrame:self.bounds];
        [_colorView.layer setCornerRadius:CGRectGetHeight(frame)/2.0];
        [_colorView.layer setMasksToBounds:YES];
        [_colorView setUserInteractionEnabled:NO];
        [self addSubview:_colorView];
    }
    return self;
}
-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [_colorView setBackgroundColor:backgroundColor];
}
-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    return self.bounds;
}
-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGRect titleRect;
    titleRect.size.width = CGRectGetWidth(contentRect);
    titleRect.size.height = 16.0;
    titleRect.origin.x = 0;
    titleRect.origin.y = CGRectGetHeight(contentRect) + 11.0;
    return titleRect;
}

@end


@interface FSLineButton : UIButton
{
    UIColor *_lineSelectColor;
}
@property(nonatomic,strong)UIView *line;
@end
@implementation FSLineButton
-(UIView *)line{
    if (!_line) {
         _line = [UIView new];
        [_line setAlpha:0];
    }
    return _line;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _lineSelectColor = FSHexRGB(0xface15);
        [self addSubview:self.line];
        
        [self setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected)];
        [self setTitleColor:FSHexRGBAlpha(0xffffff, 0.8) forState:(UIControlStateNormal)];
        
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [_line setBackgroundColor:_lineSelectColor];
    [_line setFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 2, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    [UIView animateWithDuration:0.4 animations:^{
        [_line setAlpha:selected];
    }];
    
}
@end

#define FxIdKey @"FxIdKey"
@interface FSVideoFxView()<FSVideoClipProgressDelegate>
{
    FSLineButton *_currentSelectButton;
    NSTimer      *_progressTimer;
    NSInteger _currentTime;
    NSString *_currentFxId;
}
@property(nonatomic,strong)FSVideoClipProgress *progress;

@property(nonatomic,strong)UILabel *tipLabel;
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)NSArray *videofxs;
@property(nonatomic,strong)NSArray *videofuncs;

@property(nonatomic,strong)NSMutableArray *fxButtons;
@property(nonatomic,strong)UIButton *unDoButton;

@end

@implementation FSVideoFxView

-(instancetype)initWithFrame:(CGRect)frame fxs:(NSArray *)fxs{
    if (self = [super initWithFrame:frame]) {
       
         self.videofxs = fxs;
        
        [self creatSubiviews];

    }
    return self;
}
-(void)setProgressBackView:(UIView *)progressBackView{
    if (!progressBackView) {
        return;
    }
    _progress.backGroundView = progressBackView;
}
-(NSMutableArray *)fxButtons{
    if (!_fxButtons) {
        _fxButtons = [NSMutableArray array];
    }
    return _fxButtons;
}
-(void)creatSubiviews{
    CGRect sframe = self.bounds;
    [self setBackgroundColor:FSHexRGB(0x000f1e)];
    // content
     _contentView = [[UIView alloc] initWithFrame:sframe];
    [_contentView setBackgroundColor:FSHexRGB(0x000f1e)];
    [self addSubview:_contentView];
    
    _progress = [[FSVideoClipProgress alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(sframe), 40)];
    _progress.delegate = self;
    [self addSubview:_progress];
    
     _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_progress.frame) + 11, CGRectGetWidth(sframe) - 30, 21)];
    [_tipLabel setText:@"选择位置后,按住使用效果"];
    [_tipLabel setFont:[UIFont systemFontOfSize:15]];
    [_tipLabel setTextColor:FSHexRGB(0xCBCBCB)];
    [_tipLabel setTextAlignment:(NSTextAlignmentLeft)];
    [self addSubview:_tipLabel];
    
    
     _unDoButton = [[UIButton alloc] initWithFrame:CGRectMake(311, CGRectGetMaxY(_progress.frame), 54, 30)];
    [_unDoButton setTitle:@"撤销" forState:(UIControlStateNormal)];
    [_unDoButton setHidden:YES];
    [_unDoButton addTarget:self action:@selector(unDoFix) forControlEvents:(UIControlEventTouchUpInside)];
    [_contentView addSubview:_unDoButton];
    
    // fx
    [self initFxs];

    // bottom
    CGFloat bottomH = 45.0;
     _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(sframe) - 45, CGRectGetWidth(sframe), bottomH)];
    [_bottomView setBackgroundColor:FSHexRGB(0x242630)];
    [self addSubview:_bottomView];
    
    FSLineButton *fxButton = [[FSLineButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(sframe)/2.0 - 1, 45)];
    [fxButton setTitle:@"滤镜特效" forState:UIControlStateNormal];
    [fxButton addTarget:self action:@selector(showFx:) forControlEvents:(UIControlEventTouchUpInside)];
    fxButton.tag = 1;
    [fxButton setSelected:YES];
    _currentSelectButton = fxButton;
    [_bottomView addSubview:fxButton];
    
    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(sframe), (bottomH - 12)/2.0, 1.0, 12)];
    [sepLine setBackgroundColor:[UIColor blackColor]];
    [sepLine setBackgroundColor:FSHexRGBAlpha(0xf5f5f5,0.2)];
    [_bottomView addSubview:sepLine];
    
    FSLineButton *timefxButton = [[FSLineButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(sframe)/2.0+1, 0, CGRectGetWidth(sframe)/2.0 - 1, 45)];
    [timefxButton setTitle:@"时间特效" forState:UIControlStateNormal];
    [timefxButton addTarget:self action:@selector(showFx:) forControlEvents:(UIControlEventTouchUpInside)];
    timefxButton.tag = 2;
    [_bottomView addSubview:timefxButton];
    
}
-(void)initFxs{
    for (UIView *button in self.fxButtons) {
        [button removeFromSuperview];
    }
    
    FSFxButton *soulfx = [[FSFxButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [soulfx setTitle:@"灵魂出窍" forState:(UIControlStateNormal)];
    [soulfx setBackgroundColor:[UIColor redColor]];
    [soulfx addTarget:self action:@selector(beginFx:) forControlEvents:(UIControlEventTouchDown)];
    [soulfx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpInside)];
    [soulfx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpOutside)];

    [soulfx setTag:1];
    objc_setAssociatedObject(soulfx, FxIdKey, @"C6273A8F-C899-4765-8BFC-E683EE37AA84", OBJC_ASSOCIATION_COPY);
    
    [_contentView addSubview:soulfx];
    
    FSFxButton *shakefx = [[FSFxButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(soulfx.frame) + FxButtonP, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [shakefx setBackgroundColor:[UIColor yellowColor]];
    [shakefx setTag:2];
    [shakefx addTarget:self action:@selector(beginFx:) forControlEvents:(UIControlEventTouchDown)];
    [shakefx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpInside)];
    [shakefx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpOutside)];

    [shakefx setTitle:@"抖动" forState:(UIControlStateNormal)];

     objc_setAssociatedObject(shakefx, FxIdKey, @"A8A4344D-45DA-460F-A18F-C0E2355FE864", OBJC_ASSOCIATION_COPY);

    [_contentView addSubview:shakefx];
    
    [self.fxButtons removeAllObjects];
    [self.fxButtons addObjectsFromArray:@[soulfx,shakefx]];
}
-(void)unDoFix{
    NSLog(@"unDoFix");
    [_progress undoFxView];
    
    if ([self.delegate respondsToSelector:@selector(videoFxUndoPackageFx:)]) {
        [self.delegate videoFxUndoPackageFx:self];
    }
}
-(void)beginFx:(UIButton *)button{
    NSInteger tag = button.tag;
    if (tag == 1) {
        _progress.fxViewColor = [UIColor redColor];
    }else{
        _progress.fxViewColor = [UIColor whiteColor];
    }
    
    [_progress beginFxView];
    
     _currentFxId = objc_getAssociatedObject(button, FxIdKey);
}
-(void)endFx:(UIButton *)button{
    _currentFxId = nil;
    [_progress endFxView];
}
-(void)initTimeFxs{
    
    for (UIView *button in self.fxButtons) {
        [button removeFromSuperview];
    }
    
    FSFxButton *noneFx = [[FSFxButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [noneFx addTarget:self action:@selector(clickTimeFxButtion:) forControlEvents:(UIControlEventTouchUpInside)];
    [noneFx setBackgroundColor:[UIColor redColor]];
    [noneFx setTitle:@"无" forState:(UIControlStateNormal)];
    noneFx.tag = FSVideoFxTypeNone;

    [_contentView addSubview:noneFx];
    
    FSFxButton *revertFx = [[FSFxButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(noneFx.frame) + FxButtonP, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [revertFx addTarget:self action:@selector(clickTimeFxButtion:) forControlEvents:(UIControlEventTouchUpInside)];
    [revertFx setBackgroundColor:[UIColor yellowColor]];
    [revertFx setTitle:@"时光倒流" forState:(UIControlStateNormal)];
     revertFx.tag = FSVideoFxTypeRevert;

    [_contentView addSubview:revertFx];
    
    
    FSFxButton *repeatFx = [[FSFxButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(revertFx.frame) + FxButtonP, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [repeatFx addTarget:self action:@selector(clickTimeFxButtion:) forControlEvents:(UIControlEventTouchUpInside)];
    [repeatFx setBackgroundColor:[UIColor yellowColor]];
    [repeatFx setTitle:@"反复" forState:(UIControlStateNormal)];
     repeatFx.tag = FSVideoFxTypeRepeat;
    [_contentView addSubview:repeatFx];
    
    FSFxButton *slowFx = [[FSFxButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(repeatFx.frame) + FxButtonP, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [slowFx addTarget:self action:@selector(clickTimeFxButtion:) forControlEvents:(UIControlEventTouchUpInside)];
    [slowFx setBackgroundColor:[UIColor yellowColor]];
    [slowFx setTitle:@"慢动作" forState:(UIControlStateNormal)];
     slowFx.tag = FSVideoFxTypeSlow;
    [_contentView addSubview:slowFx];
    
    [self.fxButtons removeAllObjects];
    [self.fxButtons addObjectsFromArray:@[noneFx,revertFx,repeatFx,slowFx]];
}
-(void)clickTimeFxButtion:(UIButton *)button{
    _progress.type = button.tag;
    
    if ([self.delegate respondsToSelector:@selector(videoFxViewSelectTimeFx:type:duration:progress:)]) {
        [self.delegate videoFxViewSelectTimeFx:self type:button.tag duration:1000000 progress:_progress.selectProgress];
    }
}

#pragma mark - FSVideoClipProgressDelegate
- (void)FSVideoClipProgressUpdateProgress:(CGFloat)progress {
    NSLog(@"UpdateProgress:  %f",progress);
    if ([self.delegate respondsToSelector:@selector(videoFxSelectProgress:progress:packageFxId:)]) {
        [self.delegate videoFxSelectProgress:self progress:progress packageFxId:_currentFxId];
    }
}
-(void)videoClipProgressUndoState:(BOOL)shouldShow{
    [_unDoButton setHidden:!shouldShow];
}
#pragma mark - 
-(void)showFx:(FSLineButton *)button{
    if ([_currentSelectButton isEqual:button]) {
        return;
    }
    [_currentSelectButton setSelected:NO];
    _currentSelectButton = button;
    [_currentSelectButton setSelected:YES];
    
    [_contentView setAlpha:0];
    NSInteger tag = _currentSelectButton.tag;

    [UIView animateWithDuration:0.5 animations:^{
        [self changeContentWithTag:tag];
        [_contentView setAlpha:1];
    } completion:nil];
}
-(void)changeContentWithTag:(NSInteger)tag{
    if (tag == 1) {
        [_tipLabel setText:@"选择位置后,按住使用效果"];
        [self initFxs];
    }else if (tag == 2){
        [_tipLabel setText:@"点击选择时间特效"];
        [self initTimeFxs];
    }
    
    [_unDoButton setHidden:(tag == 2)|| _progress.fiterCout == 0];
    [_progress setFtype:(tag - 1)];
}
-(void)start{
    if (!_progressTimer) {
        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateClipProgress) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_progressTimer forMode:NSRunLoopCommonModes];
    }
    [_progressTimer setFireDate:[NSDate distantPast]];
}
-(void)stop{

    [_progressTimer setFireDate:[NSDate distantFuture]];
    [_progressTimer invalidate];
    _progressTimer = nil;

}
-(void)updateClipProgress{
    if ([self.delegate respondsToSelector:@selector(videoFxViewUpdateProgress:)]) {
        CGFloat progress = [self.delegate videoFxViewUpdateProgress:self];
        _progress.progress = progress;
    }
}

-(void)hideUndoButton{
    [_unDoButton setHidden:YES];
}
-(void)showUndoButton{
    [_unDoButton setHidden:NO];
}
-(void)dealloc{
    NSLog(@"%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
@end
