//
//  FSVideoFxView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoFxView.h"
#import <objc/runtime.h>
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"
#import "UIImage+GIF.h"

#define FxButtonH 50.0
#define FxButtonP 30.0

@interface FSUndoButton : UIButton

@end
@implementation FSUndoButton

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self.layer setCornerRadius:5.0];
        [self.layer setMasksToBounds:YES];
        [self setBackgroundColor:FSHexRGB(0x2f323e)];
        [self setTitleColor:FSHexRGB(0xb8b9bd) forState:(UIControlStateNormal)];
    }
    return self;
}
-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat imagex = 5.0;
    CGFloat imagey = 5.0;
    CGFloat imagew = 19.0;
    return CGRectMake(imagex, imagey, imagew, imagew);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat titleX = CGRectGetMaxX([self imageRectForContentRect:contentRect]) + 2.0;
    CGFloat titleH = 16.0;
    CGFloat titleY = (CGRectGetHeight(contentRect) - titleH)/2.0;
    CGFloat titleW = CGRectGetWidth(contentRect) - 19.0 - 7.0 - 5.0;
    return CGRectMake(titleX, titleY, titleW, titleH);
}
@end

@interface FSFxButton : UIButton
@property(nonatomic,strong)UIView *colorView;
@property(nonatomic,strong)UIColor *fxColor;
@property(nonatomic,strong)UIImageView *selectedImage;
@property(nonatomic,strong)UIImageView *backImage;
@property(nonatomic,assign)BOOL showMask;
@end
@implementation FSFxButton
-(UIImageView *)selectedImage{
    if (!_selectedImage) {
        _selectedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"room_btn_yes"]];
    }
    return _selectedImage;
}
-(UIImageView *)backImage{
    if (!_backImage) {
        _backImage = [[UIImageView alloc] init];
    }
    return _backImage;
}
-(void)setShowMask:(BOOL)showMask{
    _showMask = showMask;
    [self.colorView setHidden:!showMask];
}
-(void)setFxColor:(UIColor *)fxColor{
    _fxColor = fxColor;
    
    [self.colorView setBackgroundColor:fxColor];
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setClipsToBounds:NO];
        
        [[UIView new] snapshotViewAfterScreenUpdates:NO];
        
        [self.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
        [self.titleLabel setTextAlignment:(NSTextAlignmentCenter)];
        [self setTitleColor:FSHexRGB(0xf5f5f5) forState:(UIControlStateNormal)];
        
        [self.backImage setFrame:CGRectMake(0.5, 0.5, CGRectGetWidth(self.bounds) - 1.0, CGRectGetHeight(self.bounds) - 1.0)];
        [self.backImage.layer setCornerRadius:CGRectGetHeight(frame)/2.0];
        [self.backImage.layer setMasksToBounds:YES];
        [self addSubview:self.backImage];

         _colorView = [[UIView alloc] initWithFrame:self.bounds];
        [_colorView.layer setCornerRadius:CGRectGetHeight(frame)/2.0];
        [_colorView.layer setMasksToBounds:YES];
        [_colorView setUserInteractionEnabled:NO];
        [_colorView setHidden:YES];
        [self addSubview:_colorView];
        
        [self.selectedImage setFrame:CGRectMake(0, 0, 22, 17)];
        [self.selectedImage setCenter:CGPointMake(CGRectGetWidth(frame)/2.0, CGRectGetHeight(frame)/2.0)];
        [self.selectedImage setHidden:YES];
        [self addSubview:self.selectedImage];
        
        [self setContentHorizontalAlignment:(UIControlContentHorizontalAlignmentCenter)];
    }
    return self;
}
-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [self.backImage setBackgroundColor:backgroundColor];
}
-(void)setImage:(UIImage *)image forState:(UIControlState)state{
    [self.backImage setImage:image];
}
-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    return self.bounds;
}
-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGRect titleRect;
    titleRect.size.width = CGRectGetWidth(contentRect)*2;
    titleRect.size.height = 16.0;
    titleRect.origin.x = -CGRectGetWidth(contentRect)/2.0;
    titleRect.origin.y = CGRectGetHeight(contentRect) + 11.0;
    return titleRect;
}
-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    [self.colorView setHidden:!selected];
    [self.selectedImage setHidden:!selected];
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
        
        [self setTitleColor:FSHexRGBAlpha(0xffffff, 1.0) forState:(UIControlStateSelected)];
        [self setTitleColor:FSHexRGBAlpha(0xffffff, 0.6) forState:(UIControlStateNormal)];
        
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
    FSFxButton   *_currentSelectFxButton;
    NSTimer      *_progressTimer;
    NSInteger _currentTime;
    NSString *_currentFxId;
    
    CGFloat _repeatPoint;
    CGFloat _slowPoint;
    
    BOOL _firstInitTimeFx;
}
@property(nonatomic,strong)FSVideoClipProgress *progress;

@property(nonatomic,strong)UILabel *tipLabel;
@property(nonatomic,strong)UIScrollView *contentView;
@property(nonatomic,strong)UIScrollView *contentTimeView;
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)NSArray *videofxs;
@property(nonatomic,strong)NSArray *videofuncs;

@property(nonatomic,strong)FSUndoButton *unDoButton;
@property(nonatomic,strong)NSMutableDictionary *fxButtonDict;
@end

@implementation FSVideoFxView

-(NSMutableDictionary *)fxButtonDict{
    if (!_fxButtonDict) {
        _fxButtonDict = [NSMutableDictionary dictionary];
    }
    return _fxButtonDict;
}
-(instancetype)initWithFrame:(CGRect)frame fxs:(NSArray *)fxs{
    if (self = [super initWithFrame:frame]) {
       
         self.videofxs = fxs;
        _firstInitTimeFx = NO;
        _repeatPoint = 0.5;
        _slowPoint = 0.5;
        [self creatSubiviews];

    }
    return self;
}
-(void)setFxType:(FSVideoFxType)fxType{
    _fxType = fxType;
    
    if (_fxType == FSVideoFxTypeRepeat) {
        _repeatPoint = _tintPositon;
        _slowPoint = 0.5;
    }else if(_fxType == FSVideoFxTypeSlow){
        _slowPoint = _tintPositon;
        _repeatPoint = 0.5;
    }else{
        _repeatPoint = 0.5;
        _slowPoint = 0.5;
    }
}
-(void)setProgressBackView:(UIView *)progressBackView{
    if (!progressBackView) {
        return;
    }
    _progress.backGroundView = progressBackView;
}
-(void)setTintPositon:(CGFloat)tintPositon{
    _tintPositon = tintPositon;
}
-(void)setIsPlaying:(BOOL)isPlaying{
    
    _isPlaying = isPlaying;
    [_progress setIsPlaying:isPlaying];
}

-(void)creatSubiviews{
    CGRect sframe = self.bounds;
    [self setBackgroundColor:FSHexRGB(0x000f1e)];
    // content
     _contentView = [[UIScrollView alloc] initWithFrame:sframe];
    [_contentView setShowsHorizontalScrollIndicator:NO];
    [_contentView setAlwaysBounceHorizontal:NO];
    [_contentView setBackgroundColor:FSHexRGB(0x000f1e)];
    [self addSubview:_contentView];
    
     _contentTimeView = [[UIScrollView alloc] initWithFrame:sframe];
    [_contentTimeView setShowsHorizontalScrollIndicator:NO];
    [_contentTimeView setAlwaysBounceHorizontal:NO];
    [_contentTimeView setBackgroundColor:FSHexRGB(0x000f1e)];
    [_contentTimeView setHidden:YES];
    [self addSubview:_contentTimeView];
    
    _progress = [[FSVideoClipProgress alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(sframe), 40)];
    _progress.delegate = self;
    [self addSubview:_progress];
    
    
    NSString *undoText = [FSShortLanguage CustomLocalizedStringFromTable:@"Delete"];
    // new code
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:11.0]};
    CGRect newSize = [undoText boundingRectWithSize:CGSizeMake(0,MAXFLOAT) options:(NSStringDrawingUsesFontLeading) attributes:dict context:nil];
    CGFloat buttonWidth = CGRectGetWidth(newSize) + 19.0 + 7.0 + 5.0;
    
     _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_progress.frame) + 11, CGRectGetWidth(sframe) - 30 - buttonWidth, 21)];
    [_tipLabel setText:[FSShortLanguage CustomLocalizedStringFromTable:@"AddFilterTip"]];
    [_tipLabel setFont:[UIFont systemFontOfSize:15]];
    [_tipLabel setTextColor:FSHexRGB(0xCBCBCB)];
    [_tipLabel setTextAlignment:(NSTextAlignmentLeft)];
    [self addSubview:_tipLabel];
    
     _unDoButton = [[FSUndoButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(sframe)-10-buttonWidth, CGRectGetMaxY(_progress.frame),buttonWidth, 30)];
    [_unDoButton setTitle:undoText forState:(UIControlStateNormal)];
    [_unDoButton.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    [_unDoButton setImage:[UIImage imageNamed:@"fxUndo"] forState:(UIControlStateNormal)];
    [_unDoButton setHidden:YES];
    [_unDoButton addTarget:self action:@selector(unDoFix) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:_unDoButton];
    
//    // fx
//    [self initFilerFxs];
//    // time
//    [self initTimeFxs];

    // bottom
    CGFloat bottomH = 45.0;
     _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(sframe) - 45, CGRectGetWidth(sframe), bottomH)];
    [_bottomView setBackgroundColor:FSHexRGB(0x242630)];
    [self addSubview:_bottomView];
    
    FSLineButton *fxButton = [[FSLineButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(sframe)/2.0 - 1, 45)];
    [fxButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Filters"] forState:UIControlStateNormal];
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
    [timefxButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Timeline"] forState:UIControlStateNormal];
    [timefxButton addTarget:self action:@selector(showFx:) forControlEvents:(UIControlEventTouchUpInside)];
    timefxButton.tag = 2;
    [_bottomView addSubview:timefxButton];
    
}
-(void)initFilerFxs{

    FSFxButton *soulfx = [[FSFxButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [soulfx setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Magic"] forState:(UIControlStateNormal)];
    [soulfx setBackgroundColor:[UIColor redColor]];
    [soulfx setImage:[UIImage sd_animatedGIFNamed:@"soul"] forState:(UIControlStateNormal)];
    [soulfx addTarget:self action:@selector(beginFx:) forControlEvents:(UIControlEventTouchDown)];
    [soulfx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpInside)];
    [soulfx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpOutside)];
    [soulfx setFxColor:FSHexRGBAlpha(0x01feff, 0.95)];
    [soulfx setTag:1];
    objc_setAssociatedObject(soulfx, FxIdKey, @"C6273A8F-C899-4765-8BFC-E683EE37AA84", OBJC_ASSOCIATION_COPY);
    [_contentView addSubview:soulfx];
    
    FSFxButton *shakefx = [[FSFxButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(soulfx.frame) + FxButtonP, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [shakefx setBackgroundColor:[UIColor yellowColor]];
    [shakefx setTag:2];
    [shakefx setImage:[UIImage sd_animatedGIFNamed:@"shake"] forState:(UIControlStateNormal)];
    [shakefx addTarget:self action:@selector(beginFx:) forControlEvents:(UIControlEventTouchDown)];
    [shakefx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpInside)];
    [shakefx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpOutside)];
    [shakefx setFxColor:FSHexRGBAlpha(0x9c01ff, 0.95)];

    [shakefx setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Vibrating"] forState:(UIControlStateNormal)];

     objc_setAssociatedObject(shakefx, FxIdKey, @"A8A4344D-45DA-460F-A18F-C0E2355FE864", OBJC_ASSOCIATION_COPY);

    [_contentView addSubview:shakefx];
    
    
    FSFxButton *jzfx = [[FSFxButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(shakefx.frame) + FxButtonP, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [jzfx setBackgroundColor:[UIColor yellowColor]];
    [jzfx setTag:3];
    [jzfx setImage:[UIImage sd_animatedGIFNamed:@"x_signal"] forState:(UIControlStateNormal)];
    [jzfx addTarget:self action:@selector(beginFx:) forControlEvents:(UIControlEventTouchDown)];
    [jzfx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpInside)];
    [jzfx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpOutside)];
    [jzfx setFxColor:FSHexRGBAlpha(0xff39ad, 0.95)];

    [jzfx setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"xsignal"] forState:(UIControlStateNormal)];
    objc_setAssociatedObject(jzfx, FxIdKey, @"9AC28816-639F-4A9B-B4BA-4060ABD229A2", OBJC_ASSOCIATION_COPY);
    
    [_contentView addSubview:jzfx];
    
    FSFxButton *fmfx = [[FSFxButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(jzfx.frame) + FxButtonP, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [fmfx setBackgroundColor:[UIColor yellowColor]];
    [fmfx setTag:4];
    [fmfx setImage:[UIImage sd_animatedGIFNamed:@"mirror"] forState:(UIControlStateNormal)];
    [fmfx addTarget:self action:@selector(beginFx:) forControlEvents:(UIControlEventTouchDown)];
    [fmfx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpInside)];
    [fmfx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpOutside)];
    [fmfx setFxColor:FSHexRGBAlpha(0xffe139, 0.95)];

    [fmfx setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"mirror"] forState:(UIControlStateNormal)];
    
    objc_setAssociatedObject(fmfx, FxIdKey, @"6B7BE12C-9FA1-4ED0-8E81-E107632FFBC8", OBJC_ASSOCIATION_COPY);
    [_contentView addSubview:fmfx];
    
    
    FSFxButton *hjfx = [[FSFxButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(fmfx.frame) + FxButtonP, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [hjfx setBackgroundColor:[UIColor yellowColor]];
    [hjfx setTag:6];
    [hjfx setImage:[UIImage sd_animatedGIFNamed:@"huanjue"] forState:(UIControlStateNormal)];
    [hjfx addTarget:self action:@selector(beginFx:) forControlEvents:(UIControlEventTouchDown)];
    [hjfx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpInside)];
    [hjfx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpOutside)];
    [hjfx setFxColor:FSHexRGBAlpha(0x6339ff, 0.95)];

    [hjfx setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"huanjue"] forState:(UIControlStateNormal)];
    
    objc_setAssociatedObject(hjfx, FxIdKey, @"Video Echo", OBJC_ASSOCIATION_COPY);
    [_contentView addSubview:hjfx];
    
    
    
    FSFxButton *bmfx = [[FSFxButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(hjfx.frame) + FxButtonP, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [bmfx setBackgroundColor:[UIColor yellowColor]];
    [bmfx setTag:5];
    [bmfx setImage:[UIImage sd_animatedGIFNamed:@"black_magic"] forState:(UIControlStateNormal)];
    [bmfx addTarget:self action:@selector(beginFx:) forControlEvents:(UIControlEventTouchDown)];
    [bmfx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpInside)];
    [bmfx addTarget:self action:@selector(endFx:) forControlEvents:(UIControlEventTouchUpOutside)];
    [bmfx setFxColor:FSHexRGBAlpha(0x39ff9f, 0.95)];

    [bmfx setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"BW"]  forState:(UIControlStateNormal)];
    
    objc_setAssociatedObject(bmfx, FxIdKey, @"33F513E5-5CA2-4C23-A6D4-8466202EE698", OBJC_ASSOCIATION_COPY);
    [_contentView addSubview:bmfx];
    
    [_contentView setContentSize:CGSizeMake(CGRectGetMaxX(bmfx.frame) + 20, 0)];
    [_contentView setContentOffset:CGPointZero];
}
-(void)creatFxFiltterButtons{
    [self initFilerFxs];
    [self initTimeFxs];
    
    // 默认选中
    _progress.ftype = FSFilterTypeFx;
}
-(void)initTimeFxs{
    
    [self.fxButtonDict removeAllObjects];
    
    FSFxButton *noneFx = [[FSFxButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [noneFx addTarget:self action:@selector(clickTimeFxButtion:) forControlEvents:(UIControlEventTouchUpInside)];
    [noneFx setBackgroundColor:[UIColor redColor]];
    [noneFx setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"NoFilter"] forState:(UIControlStateNormal)];
     noneFx.tag = FSVideoFxTypeNone;
    [noneFx.colorView setBackgroundColor:FSHexRGBAlpha(0x000000, 0.5)];
    [noneFx setImage:[UIImage sd_animatedGIFNamed:@"Origin"] forState:(UIControlStateNormal)];
    [self.fxButtonDict setObject:noneFx forKey:[NSString stringWithFormat:@"%ld",(long)FSVideoFxTypeNone]];
    noneFx.selected = (_fxType == FSVideoFxTypeNone);

    [_contentTimeView addSubview:noneFx];
    
    FSFxButton *revertFx = [[FSFxButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(noneFx.frame) + FxButtonP, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [revertFx addTarget:self action:@selector(clickTimeFxButtion:) forControlEvents:(UIControlEventTouchUpInside)];
    [revertFx setBackgroundColor:[UIColor yellowColor]];
    [revertFx setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Reverse"] forState:(UIControlStateNormal)];
    [revertFx.colorView setBackgroundColor:FSHexRGBAlpha(0xff39ad, 0.95)];
     revertFx.tag = FSVideoFxTypeRevert;
    [revertFx setImage:[UIImage sd_animatedGIFNamed:@"revert"] forState:(UIControlStateNormal)];
    [self.fxButtonDict setObject:revertFx forKey:[NSString stringWithFormat:@"%ld",(long)FSVideoFxTypeRevert]];
    revertFx.selected = (_fxType == FSVideoFxTypeRevert);
    [_contentTimeView addSubview:revertFx];
    
    
    FSFxButton *repeatFx = [[FSFxButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(revertFx.frame) + FxButtonP, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [repeatFx addTarget:self action:@selector(clickTimeFxButtion:) forControlEvents:(UIControlEventTouchUpInside)];
    [repeatFx setBackgroundColor:[UIColor yellowColor]];
    [repeatFx setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Repeat"] forState:(UIControlStateNormal)];
    [repeatFx.colorView setBackgroundColor:FSHexRGBAlpha(0x7778ff, 0.95)];
     repeatFx.tag = FSVideoFxTypeRepeat;
    [repeatFx setImage:[UIImage sd_animatedGIFNamed:@"repeat"] forState:(UIControlStateNormal)];
    [self.fxButtonDict setObject:repeatFx forKey:[NSString stringWithFormat:@"%ld",(long)FSVideoFxTypeRepeat]];
    repeatFx.selected = (_fxType == FSVideoFxTypeRepeat);

    [_contentTimeView addSubview:repeatFx];
    
    FSFxButton *slowFx = [[FSFxButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(repeatFx.frame) + FxButtonP, CGRectGetMaxY(_tipLabel.frame) + 24, FxButtonH, FxButtonH)];
    [slowFx addTarget:self action:@selector(clickTimeFxButtion:) forControlEvents:(UIControlEventTouchUpInside)];
    [slowFx setBackgroundColor:[UIColor yellowColor]];
    [slowFx setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"SlowMotion"] forState:(UIControlStateNormal)];
    [slowFx.colorView setBackgroundColor:FSHexRGBAlpha(0xbcff77, 0.95)];
     slowFx.tag = FSVideoFxTypeSlow;
    [slowFx setImage:[UIImage sd_animatedGIFNamed:@"slow"] forState:(UIControlStateNormal)];
    [self.fxButtonDict setObject:slowFx forKey:[NSString stringWithFormat:@"%ld",(long)FSVideoFxTypeSlow]];
    slowFx.selected = (_fxType == FSVideoFxTypeSlow);

    [_contentTimeView addSubview:slowFx];
    [_contentTimeView setContentSize:CGSizeMake(CGRectGetMaxX(slowFx.frame) + 20, 0)];
    [_contentTimeView setContentOffset:CGPointZero];

    
    if (!_firstInitTimeFx) {
        [_progress setType:_fxType];
        [_progress setTintPosition:_tintPositon];
        [_progress setNeedConvert:_needCovert];
        if (_needCovert) {
            [_progress setProgress:1.0];
        }
         _firstInitTimeFx = YES;
    }
    
    NSString *key = [NSString stringWithFormat:@"%ld",(long)_fxType];
     _currentSelectFxButton = [self.fxButtonDict objectForKey:key];
    [_currentSelectFxButton setSelected:YES];
}
-(void)setNeedCovert:(BOOL)needCovert{
     _needCovert = needCovert;
}
-(void)setDuration:(CGFloat)duration{
    _duration = duration;
    CGFloat width = CGRectGetWidth(self.bounds);
    if (_duration == 0) {
        _progress.vSpeed = 2.0;
    }else{
        _progress.vSpeed = width/_duration *0.1;
    }
}
#pragma mark - 动作
-(void)beginFx:(FSFxButton *)button{
    
    if (_currentFxId != nil) {
        NSLog(@"正在添加特效 不能多次处理 %@",_currentFxId);
        return;
    }
    _progress.fxViewColor = button.fxColor;
    _currentFxId = objc_getAssociatedObject(button, FxIdKey);
    [button setShowMask:YES];
    [_progress beginFxView];
    NSLog(@"正在添加特效 %@",_currentFxId);

}
-(void)endFx:(FSFxButton *)button{
    
    NSString *endButtonFxId = objc_getAssociatedObject(button, FxIdKey);
    if (![endButtonFxId isEqualToString:_currentFxId]) {
        NSLog(@"正在添加特效 不能直接处理处理 %@",_currentFxId);
        return;
    }
    
    [button setShowMask:NO];
    [_progress endFxView:YES];
    NSLog(@"正在添加特效 结束添加 %@",_currentFxId);

     _currentFxId = nil;
}
#pragma mark - 选择时间特效
-(void)clickTimeFxButtion:(FSFxButton *)button{
    if ([_currentSelectFxButton isEqual:button]) {
        return;
    }
    [_currentSelectFxButton setSelected:NO];
     _currentSelectFxButton = button;
    [_currentSelectFxButton setSelected:YES];

     _progress.type = button.tag;

    _fxType = button.tag;
    // 切换资源
    if (button.tag == FSVideoFxTypeRevert) {
        [_progress setProgress:1];
    }else if(button.tag == FSVideoFxTypeSlow){
        [_progress setProgress:_slowPoint];
    }else if (button.tag == FSVideoFxTypeRepeat){
        [_progress setProgress:_repeatPoint];
    }else if (button.tag == FSVideoFxTypeNone){
        [_progress setProgress:0.0];
    }

    BOOL newValue = (button.tag == FSVideoFxTypeRevert);
    [_progress setNeedConvert:newValue];

    if (_needCovert != newValue) {
        if ([self.delegate respondsToSelector:@selector(videoFxViewNeedConvertView:type:)]) {
            [self.delegate videoFxViewNeedConvertView:newValue type:_fxType];
        }
        _needCovert = newValue;
    }
    if (button.tag != FSVideoFxTypeRevert) {
        // 修改选中点
        [_progress setSelectProgress:_progress.progress];
        
        if ([self.delegate respondsToSelector:@selector(videoFxViewSelectTimeFx:type:duration:progress:)]) {
            [self.delegate videoFxViewSelectTimeFx:self type:button.tag duration:200000 progress:_progress.selectProgress];
        }
    }
}
#pragma mark - FSVideoClipProgressDelegate
- (void)videoClipProgressSelectPoint:(CGFloat)progress{
    if ([self.delegate respondsToSelector:@selector(videoFxSelectTimeLinePosition:position:shouldPlay:)]) {
        [self.delegate videoFxSelectTimeLinePosition:self position:progress shouldPlay:NO];
    }
}
- (void)videoClipProgressMoveSlideSelectPoint:(CGFloat)progress{
    
    if (_fxType == FSVideoFxTypeRepeat) {
        _repeatPoint = progress;
    }else if (_fxType == FSVideoFxTypeSlow){
        _slowPoint = progress;
    }
    if ([self.delegate respondsToSelector:@selector(videoFxViewSelectTimeFx:type:duration:progress:)]) {
        [self.delegate videoFxViewSelectTimeFx:self type:_fxType duration:200000 progress:_progress.selectProgress];
    }
}
-(void)videoClipProgressStartSelect:(CGFloat)progress{
    if ([self.delegate respondsToSelector:@selector(videoFxSelectStart:progress:packageFxId:)]) {
        [self.delegate videoFxSelectStart:self progress:progress packageFxId:_currentFxId];
    }
}

-(void)videoClipProgressEndSelect:(CGFloat)progress{
    if ([self.delegate respondsToSelector:@selector(videoFxSelectEnd:progress:packageFxId:)]) {
        [self.delegate videoFxSelectEnd:self progress:progress packageFxId:_currentFxId];
    }
}
-(NSArray *)addedViews{
    return _progress.renderRangeViews;
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
        [_tipLabel setText:[FSShortLanguage CustomLocalizedStringFromTable:@"AddFilterTip"]];
//        [self initFilerFxs];
        [_contentView setHidden:NO];
        [_contentTimeView setHidden:YES];
    }else if (tag == 2){
        [_tipLabel setText:[FSShortLanguage CustomLocalizedStringFromTable:@"ChooseEffectsTip"]];
//        [self initTimeFxs];
        [_contentView setHidden:YES];
        [_contentTimeView setHidden:NO];
    }
    if ([self.delegate respondsToSelector:@selector(videoFxViewChangeFilter)]) {
        [self.delegate videoFxViewChangeFilter];
    }
    
    [_unDoButton setHidden:(tag == 2)|| _progress.fiterCout == 0];
    [_progress setFtype:(tag - 1)];
}
#pragma mark - 更新progress 上的进度
-(void)startMoveTint{
    if (!_progressTimer) {
         _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(moveProgressBarTint) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_progressTimer forMode:NSRunLoopCommonModes];
    }
    [_progressTimer setFireDate:[NSDate distantPast]];
}
-(void)stopMoveTint{
    [_progressTimer setFireDate:[NSDate distantFuture]];
    [_progressTimer invalidate];
     _progressTimer = nil;
}
-(void)moveProgressBarTint{
    if ([self.delegate respondsToSelector:@selector(videoFxViewUpdatePosition:)]) {
        CGFloat progress = [self.delegate videoFxViewUpdatePosition:self];
        _progress.progress = _progress.needConvert?(1-progress):progress;
    }
}
-(void)addFiltterViews:(NSArray *)filterViews{
    [_progress addFitteredView:filterViews];
    // 重新展示
    if([filterViews count]){
        [self showUndoButton];
    }
}
#pragma mark - 展示影藏撤销按钮
-(void)hideUndoButton{
    [_unDoButton setHidden:YES];
}
-(void)showUndoButton{
    [_unDoButton setHidden:NO];
}
// 撤销特效
-(void)unDoFix{
    NSLog(@"unDoFix");
    [_progress undoFxView];
    
    [_unDoButton setHidden:_progress.fiterCout == 0 ? YES : NO];
    
    if ([self.delegate respondsToSelector:@selector(videoFxUndoPackageFx:)]) {
        [self.delegate videoFxUndoPackageFx:self];
    }
}
#pragma mark - 翻转
-(void)dealloc{
    NSLog(@"%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}
@end
