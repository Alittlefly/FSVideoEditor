//
//  FSSegmentView.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/28.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSSegmentView.h"

@interface FSSegmentView()

@property (nonatomic, strong) NSArray *itmesArray;
@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation FSSegmentView

- (instancetype)initWithItems:(NSArray *)itmes {
    if (self = [super init]) {
        _itmesArray = [NSArray arrayWithArray:itmes];
        _buttonArray = [NSMutableArray arrayWithCapacity:0];
        _selectedTextColor = [UIColor whiteColor];
        _unSelectedTextColor = [UIColor blackColor];
        _selectedSegmentIndex = -1;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.buttonArray.count > 0) {
        for (int i = 0; i < self.buttonArray.count; i++) {
            UIButton *button = [self.buttonArray objectAtIndex:i];
            CGFloat width = self.bounds.size.width/self.itmesArray.count;
            button.frame = CGRectMake(i*width, 0, width, self.bounds.size.height);
        }
    }
    else {
        for (int i = 0; i < self.itmesArray.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            CGFloat width = self.bounds.size.width/self.itmesArray.count;
            button.frame = CGRectMake(i*width, 0, width, self.bounds.size.height);
            button.tag = i;
            [button.titleLabel setFont:[UIFont systemFontOfSize:10]];
            [button setTitleColor:_unSelectedTextColor forState:UIControlStateNormal];
            [button addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            id item = [self.itmesArray objectAtIndex:i];
            if ([item isKindOfClass:[NSString class]]) {
                [button setTitle:item forState:UIControlStateNormal];
            }
            else if ([item isKindOfClass:[UIImage class]]) {
                [button setImage:item forState:UIControlStateNormal];
            }
            
            if (_selectedSegmentIndex != -1) {
                if (button.tag == _selectedSegmentIndex) {
                    [button setBackgroundColor:_selectedColor];
                    [button setTitleColor:_selectedTextColor forState:UIControlStateNormal];
                }
                else {
                    [button setBackgroundColor:[UIColor clearColor]];
                    [button setTitleColor:_unSelectedTextColor forState:UIControlStateNormal];
                }
            }
            
            [self addSubview:button];
            
            [self.buttonArray addObject:button];
        }
    }
}

- (void)clickBtn:(UIButton *)sender {
    
    for (UIButton *button in self.buttonArray) {
        if (button.tag == sender.tag) {
            [button setBackgroundColor:_selectedColor];
            [button setTitleColor:_selectedTextColor forState:UIControlStateNormal];
        }
        else {
            [button setBackgroundColor:[UIColor clearColor]];
            [button setTitleColor:_unSelectedTextColor forState:UIControlStateNormal];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(FSSegmentView:selected:)]) {
        [self.delegate FSSegmentView:self selected:sender.tag];
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    _selectedSegmentIndex = selectedSegmentIndex;
    
    if (self.buttonArray.count > 0) {
        for (UIButton *button in self.buttonArray) {
            if (button.tag == selectedSegmentIndex) {
                [button setBackgroundColor:_selectedColor];
                [button setTitleColor:_selectedTextColor forState:UIControlStateNormal];
            }
            else {
                [button setBackgroundColor:[UIColor clearColor]];
                [button setTitleColor:_unSelectedTextColor forState:UIControlStateNormal];
            }
        }
    }
}

@end
