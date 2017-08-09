//
//  FSSearchBar.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSSearchBar.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"

@interface FSSearchBar()

@property(nonatomic,strong)UISearchBar *searchBar;
@property(nonatomic,strong)UIView *backView;
@property(nonatomic,assign)id<UISearchBarDelegate>delegate;
@property(nonatomic,strong)UIButton *cancleButton;

@end

@implementation FSSearchBar

-(instancetype)initWithFrame:(CGRect)frame delegate:(id<UISearchBarDelegate>)delegate{
    if (self = [super initWithFrame:frame]) {
        [self setDelegate:delegate];
        [self creatSubviews:frame];
    }
    return self;
}
-(void)setShowCancle:(BOOL)showCancle{
     _showCancle = showCancle;
    [_cancleButton setHidden:!showCancle];
    
    if (showCancle) {
        CGRect cancleRect = _cancleButton.frame;
        CGRect searchFrame = _searchBar.frame;
        if ([FSPublishSingleton sharedInstance].isAutoReverse) {
            searchFrame.origin.x = CGRectGetMaxX(cancleRect)+15;
            searchFrame.size.width = self.bounds.size.width - CGRectGetMaxX(cancleRect) - 15;
        }
        else {
            searchFrame.origin.x = 0;
            searchFrame.size.width = CGRectGetMinX(cancleRect) - 15;
        }
        [_searchBar setFrame:searchFrame];
        [_backView setFrame:searchFrame];
    }else{
        [_backView setFrame:self.bounds];
        [_searchBar setFrame:self.bounds];
    }
    
    
}
-(void)creatSubviews:(CGRect)frame{
    
     _backView = [UIView new];
    [_backView.layer setCornerRadius:CGRectGetHeight(frame)/2.0];
    [_backView.layer setMasksToBounds:YES];
    [_backView setFrame:self.bounds];
    [_backView setBackgroundColor:FSHexRGB(0xf1f1f2)];
    [_backView setUserInteractionEnabled:NO];
    [self addSubview:_backView];
    
     _searchBar = [[UISearchBar alloc] initWithFrame:self.bounds];
    [_searchBar setPlaceholder:[FSShortLanguage CustomLocalizedStringFromTable:@"SearchMusic"]];
    [_searchBar setBackgroundImage:[UIImage new] forBarPosition:(UIBarPositionAny) barMetrics:(UIBarMetricsDefault)];
    [_searchBar setBarTintColor:[UIColor clearColor]];
    [_searchBar setDelegate:_delegate];
    [_searchBar setTranslucent:YES];
    UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
    searchField.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_searchBar];
    
     _cancleButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [_cancleButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Cancel"] forState:(UIControlStateNormal)];
    [_cancleButton sizeToFit];
    [_cancleButton setFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 20 : CGRectGetWidth(self.bounds) - 20 - CGRectGetWidth(_cancleButton.frame), (CGRectGetHeight(self.bounds) - CGRectGetHeight(_cancleButton.frame))/2.0,  CGRectGetWidth(_cancleButton.frame), CGRectGetHeight(_cancleButton.frame))];
    [_cancleButton setTitleColor:FSHexRGB(0x0bc2c6) forState:(UIControlStateNormal)];
    [_cancleButton addTarget:self action:@selector(cancleSearch) forControlEvents:(UIControlEventTouchUpInside)];
    [_cancleButton setHidden:YES];
    [self addSubview:_cancleButton];
    
}
-(void)cancleSearch{
    
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.delegate searchBarCancelButtonClicked:_searchBar];
    }
    
    if ([_searchBar canResignFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
    
    [_searchBar setText:@""];
    [self setShowCancle:NO];
}

@end
