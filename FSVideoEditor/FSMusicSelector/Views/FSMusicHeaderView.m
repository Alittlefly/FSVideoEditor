//
//  FSMusicHeaderView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicHeaderView.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"
#import "UIButton+WebCache.h"
#import "FSPublishSingleton.h"

@interface FSMusicTypeButton : UIButton
@property(nonatomic,strong)FSMusicType *musicType;
@end
@implementation FSMusicTypeButton
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setTitleColor:FSHexRGB(0xa2a4a1) forState:(UIControlStateNormal)];
        [self.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [self.titleLabel setTextAlignment:(NSTextAlignmentCenter)];
    }
    return self;
}
-(void)setMusicType:(FSMusicType *)musicType{
    _musicType = musicType;
    
    [self setTitle:musicType.typeName forState:(UIControlStateNormal)];
    [self sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",AddressResource,musicType.typePic]] forState:(UIControlStateNormal) placeholderImage:[UIImage imageNamed:@"musicBtnPlaceHolder"]];
}
-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGRect imageRect = CGRectZero;
    imageRect.size.width = 35;
    imageRect.size.height = 35;
    imageRect.origin.x = (CGRectGetWidth(contentRect) - 35)/2.0;
    imageRect.origin.y = 5;
    return imageRect;
}
-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, CGRectGetHeight(contentRect) - 18.0 - 5.0, CGRectGetWidth(contentRect), 18.0);
}

@end


@interface FSMusicItemButton : UIButton

@end
@implementation FSMusicItemButton

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initStyle];
    }
    return self;
}
-(instancetype)init{
    if (self = [super init]) {
        [self initStyle];
    }
    return self;
}
-(void)initStyle{
    [self.titleLabel setTextAlignment:(NSTextAlignmentCenter)];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setTitleColor:FSHexRGB(0x0bc2c6) forState:(UIControlStateSelected)];
    [self setTitleColor:FSHexRGB(0xb8b9bd) forState:(UIControlStateNormal)];
}
@end

@interface FSMusicHeaderView()
{
    BOOL _opend;
}
@property(nonatomic,strong)FSMusicItemButton *hotMusicButton;
@property(nonatomic,strong)FSMusicItemButton *likeMusicButton;
@property(nonatomic,strong)FSMusicTypeButton *showAllButton;
@property(nonatomic,strong)UIView *hline;
@property(nonatomic,strong)UIView *vline;
@property(nonatomic,strong)NSMutableArray *musicTypeButtons;
@property(nonatomic,strong)FSMusicItemButton *currentSelected;
@end
@implementation FSMusicHeaderView
-(NSMutableArray *)musicTypeButtons{
    if (!_musicTypeButtons) {
        _musicTypeButtons = [NSMutableArray array];
    }
    return _musicTypeButtons;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _opend = NO;
        [self creatSubviews:frame];
    }
    return self;
}
-(void)creatSubviews:(CGRect)frame{
    if (!_hline) {
        _hline = [UIView new];
        [_hline setBackgroundColor:FSHexRGB(0xe4e4e4)];
        [self addSubview:_hline];
    }

    if (!_hotMusicButton) {
        _hotMusicButton = [[FSMusicItemButton alloc] init];
        [_hotMusicButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"HotMusic"] forState:(UIControlStateNormal)];
        [self addSubview:_hotMusicButton];
        [_hotMusicButton addTarget:self action:@selector(clickTypeItem:) forControlEvents:(UIControlEventTouchUpInside)];
        _hotMusicButton.tag = FSMusicButtonTypeHot;
        [self setCurrentSelected:_hotMusicButton];
    }
    

    if (!_vline) {
        _vline = [UIView new];
        [_vline setBackgroundColor:FSHexRGB(0xe4e4e4)];
        [self addSubview:_vline];
    }

    if (!_likeMusicButton) {
        _likeMusicButton = [[FSMusicItemButton alloc] init];
        [_likeMusicButton setBackgroundColor:[UIColor clearColor]];
        [_likeMusicButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"likeMusic"] forState:(UIControlStateNormal)];
        [_likeMusicButton addTarget:self action:@selector(clickTypeItem:) forControlEvents:(UIControlEventTouchUpInside)];
         _likeMusicButton.tag = FSMusicButtonTypeLike;
        [self addSubview:_likeMusicButton];
    }

}
-(void)setCurrentSelected:(FSMusicItemButton *)currentSelected{
    if (_currentSelected) {
        [_currentSelected setSelected:NO];
    }
    _currentSelected = currentSelected;
    [_currentSelected setSelected:YES];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    
    [_hline setFrame:CGRectMake(10, CGRectGetHeight(frame) - 53, CGRectGetWidth(frame) - 20, 0.5)];

    [_vline setFrame:CGRectMake(CGRectGetMidX(frame), CGRectGetHeight(frame) - 52 + 18.5, 1.0, 15.0)];
    
    [_hotMusicButton setFrame:CGRectMake(0, CGRectGetHeight(frame) - 52, CGRectGetWidth(frame)/2.0- 0.5, 52)];

    [_likeMusicButton setFrame:CGRectMake(CGRectGetWidth(frame)/2.0 + 0.5, CGRectGetHeight(frame) - 52, CGRectGetWidth(frame)/2.0- 0.5, 52)];

}
-(void)setItems:(NSArray<FSMusicType *> *)items{
    
    if (_items != nil) {
        return;
    }
    _items = items;
    
    [self creatItems:_opend items:items];
    
    if ([items count] == 0) {
        CGRect frame = self.frame;
        frame.size.height = 54.0;
        if ([self.delegate respondsToSelector:@selector(musicHeaderShouldBeFrame:)]) {
            [self.delegate musicHeaderShouldBeFrame:frame];
        }
    }
}
-(void)creatItems:(BOOL)opened items:(NSArray *)items{
    NSInteger count = [items count];
    CGFloat buttonW = 68.0;
    CGFloat startPaddingX = 14.0;
    CGFloat startPaddingY = 0;
    CGFloat numberOfRow = 4.0;
    CGFloat innerPaddingX = (CGRectGetWidth(self.bounds) - buttonW * numberOfRow - startPaddingX * 2)/(numberOfRow - 1);
    CGFloat innerPaddingY = 10.0;
    
    NSInteger col = 0;
    NSInteger row = 0;
    
    for (NSInteger index = 0; index < count; index ++) {
        col = index/4;
        row = index%4;
        CGFloat btnx = startPaddingX + row *(buttonW + innerPaddingX);
        CGFloat btny = startPaddingY + col *(buttonW + innerPaddingY);
        if (index >= 7 && count > 8 && !_opend) {
            if (!_showAllButton) {
                _showAllButton = [[FSMusicTypeButton alloc] initWithFrame:CGRectMake(btnx, btny, buttonW, buttonW)];
                NSString *title = [[FSPublishSingleton sharedInstance].language isEqualToString:@"en"] ?[NSString stringWithFormat:@"%@ %ld",[FSShortLanguage CustomLocalizedStringFromTable:@"MoreTag"],count - index] : [NSString stringWithFormat:@"%ld %@",count - index,[FSShortLanguage CustomLocalizedStringFromTable:@"MoreTag"]];
                [_showAllButton addTarget:self action:@selector(showAllItems:) forControlEvents:(UIControlEventTouchUpInside)];
                [_showAllButton setImage:[UIImage imageNamed:@"musicDown"] forState:(UIControlStateNormal)];
                [_showAllButton setTitle:title forState:(UIControlStateNormal)];
                [_showAllButton setBackgroundColor:[UIColor clearColor]];
                [self addSubview:_showAllButton];
            }
            break;
        }
        
        FSMusicTypeButton *typeButton = [[FSMusicTypeButton alloc] initWithFrame:CGRectMake(btnx, btny, buttonW, buttonW)];
        typeButton.musicType = [items objectAtIndex:index];
        [typeButton addTarget:self action:@selector(clickFashino:) forControlEvents:(UIControlEventTouchUpInside)];
        [typeButton setBackgroundColor:[UIColor clearColor]];
        [self.musicTypeButtons addObject:typeButton];
        [self addSubview:typeButton];
    }
}
-(void)showAllItems:(FSMusicTypeButton *)button{
    _opend = YES;
    [button setHidden:YES];
    [button removeFromSuperview];
    
    [self creatItems:_opend items:_items];
    NSInteger count = [_items count];
    CGFloat unshowcount = count - 8.0;
    NSInteger lines = ceil(unshowcount/4.0);
    CGFloat addHeight = lines * (68 + 10);
    CGRect frame = self.frame;
    frame.size.height += addHeight;
    if ([self.delegate respondsToSelector:@selector(musicHeaderShouldBeFrame:)]) {
        [self.delegate musicHeaderShouldBeFrame:frame];
    }
}
-(void)clickTypeItem:(FSMusicItemButton *)button{
    [self setCurrentSelected:button];
    if ([self.delegate respondsToSelector:@selector(musicHeaderClickTypeButton:)]) {
        [self.delegate musicHeaderClickTypeButton:button.tag];
    }
}
-(void)clickFashino:(FSMusicTypeButton *)button{
    FSMusicType *musicType = button.musicType;
    if ([self.delegate respondsToSelector:@selector(musicHeaderViewSelectItem:)]) {
        [self.delegate musicHeaderViewSelectItem:musicType];
    }
}
@end
