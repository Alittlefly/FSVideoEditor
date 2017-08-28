//
//  FSFilterView.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSFilterView.h"
#import "FSFilterButton.h"
#import "FSShortVideoRecorderManager.h"
#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"

@interface FSFilterView()

@property (nonatomic, strong) UILabel *titLabel;
@property (nonatomic, strong) UIButton *chooseButton;
@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, strong) NSMutableArray *filtersArray;
@property (nonatomic, strong) NSMutableArray *buttonArray;
 
@end

@implementation FSFilterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 初始化视频特效列表
        _filtersArray = [NSMutableArray arrayWithObject:[FSShortLanguage CustomLocalizedStringFromTable:@"NoFilter"]];
        // 获取全部内嵌视频特效的名称
        [_filtersArray addObjectsFromArray:[[FSShortVideoRecorderManager sharedInstance] getAllVideoFilters]];
        [self initBaseUI];
    }
    return self;
}

- (void)initBaseUI {
    _titLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height/2)];
    _titLabel.textColor =[UIColor whiteColor];
    _titLabel.textAlignment = NSTextAlignmentCenter;
    _titLabel.backgroundColor = [UIColor clearColor];
    _titLabel.font = [UIFont systemFontOfSize:15];
    _titLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"ColorFilter"];//NSLocalizedString(@"ColorFilter", nil);
    _titLabel.shadowColor = [UIColor blackColor];
    //阴影偏移  x，y为正表示向右下偏移
    _titLabel.shadowOffset = CGSizeMake(1, 1);
    [_titLabel sizeToFit];
    _titLabel.frame = CGRectMake((self.frame.size.width- _titLabel.frame.size.width)/2, (self.frame.size.height/2-_titLabel.frame.size.height)/2, _titLabel.frame.size.width, _titLabel.frame.size.height);
    [self addSubview:_titLabel];
    
    _chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _chooseButton.backgroundColor = [UIColor clearColor];
    [_chooseButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
    _chooseButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 20 : self.frame.size.width-20-54, (self.frame.size.height/2-30)/2, 54, 30);
    [_chooseButton addTarget:self action:@selector(finishChooseFilter) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_chooseButton];
    
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2)];
    [_contentScrollView setBackgroundColor:[UIColor blackColor]];
    _contentScrollView.showsHorizontalScrollIndicator = YES;
    [_contentScrollView setContentSize:CGSizeMake((_contentScrollView.frame.size.height-4+5)*_filtersArray.count-5, 0)];
    [self addSubview:_contentScrollView];
    
    for (int i = 0; i < _filtersArray.count; i++) {
        NSString *filter = _filtersArray[i];
        FSFilterButton *button = [[FSFilterButton alloc] initWithFrame:CGRectMake((_contentScrollView.frame.size.height-4+5)*i, 2, _contentScrollView.frame.size.height-4, _contentScrollView.frame.size.height-4)];
        button.backgroundColor = [UIColor redColor];
        button.tag = i;
        button.title = filter;
        button.image = [UIImage imageNamed:filter];
        [button addTarget:self action:@selector(chooseFilter:) forControlEvents:UIControlEventTouchUpInside];
        [_contentScrollView addSubview:button];
    }
}

- (void)chooseFilter:(UIButton *)sender {
     NSString *fxName = [_filtersArray objectAtIndex:sender.tag];
    
    if ([self.delegate respondsToSelector:@selector(FSFilterViewChooseFilter:)]) {
        [self.delegate FSFilterViewChooseFilter:fxName];
    }
}

- (void)finishChooseFilter {
    if ([self.delegate respondsToSelector:@selector(FSFilterViewFinishedChooseFilter)]) {
        [self.delegate FSFilterViewFinishedChooseFilter];
    }
}

@end
