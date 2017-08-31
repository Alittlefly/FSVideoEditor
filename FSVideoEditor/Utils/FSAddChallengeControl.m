//
//  FSAddChallengeControl.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/8/31.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSAddChallengeControl.h"
#import "FSVideoEditorCommenData.h"
#import "FSPublishSingleton.h"

@interface FSAddChallengeControl()

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UILabel *mTitleLabel;
@property (nonatomic, strong) UIImageView *rightImageView;

@end

@implementation FSAddChallengeControl

- (UIImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] init];
        //_leftImageView.userInteractionEnabled = NO;
        [self addSubview:_leftImageView];
    }
    return _leftImageView;
}

- (UIImageView *)rightImageView {
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] init];
        //_rightImageView.userInteractionEnabled = NO;
        [self addSubview:_rightImageView];
    }
    return _rightImageView;
}

- (UILabel *)mTitleLabel {
    if (!_mTitleLabel) {
        _mTitleLabel = [[UILabel alloc] init];
        _mTitleLabel.backgroundColor = [UIColor clearColor];
        _mTitleLabel.font = [UIFont systemFontOfSize:12];
        _mTitleLabel.textColor = FSHexRGB(0xFFFFFF);
         [_mTitleLabel setShadowColor:[UIColor blackColor]];
        [_mTitleLabel setShadowOffset:CGSizeMake(1, 1)];
        //_titleLabel.userInteractionEnabled = NO;
        [self addSubview:_mTitleLabel];
    }
    return _mTitleLabel;
}

- (void)setLeftImage:(UIImage *)leftImage title:(NSString *)title rightImage:(UIImage *)rightImage {
    CGFloat width = 0;
    
    if (leftImage) {
        self.leftImageView.image = leftImage;
        self.leftImageView.frame = CGRectMake(2, (self.frame.size.height-14)/2, 12, 12);
    }
    else {
        self.leftImageView.image = nil;
        self.leftImageView.frame = CGRectZero;
    }
    width += CGRectGetWidth(self.leftImageView.frame)+2;
    
    if (title && title.length > 0) {
        self.mTitleLabel.text = title;
        [self.mTitleLabel sizeToFit];
        
        //CGSize size = [title boundingRectWithSize:CGSizeMake(999, 27) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size;
        CGFloat width = self.mTitleLabel.frame.size.width;
        if (width+4 > _maxWidth) {
            width = _maxWidth;
        }
        
        self.mTitleLabel.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? CGRectGetMaxX(self.leftImageView.frame)+5:CGRectGetMaxX(self.leftImageView.frame), 0, width, self.frame.size.height);
    }
    else {
        self.mTitleLabel.text = @"";
        self.mTitleLabel.frame = CGRectZero;
    }
    width += (CGRectGetWidth(self.mTitleLabel.frame)+([FSPublishSingleton sharedInstance].isAutoReverse ? 5:0));

    
    if (rightImage) {
        self.rightImageView.image = rightImage;
        self.rightImageView.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? CGRectGetMaxX(self.mTitleLabel.frame):CGRectGetMaxX(self.mTitleLabel.frame)+5, (self.frame.size.height-12)/2, 12, 12);
    }
    else {
        self.rightImageView.image = nil;
        self.rightImageView.frame = CGRectZero;
    }
    width += (CGRectGetWidth(self.rightImageView.frame)+2+([FSPublishSingleton sharedInstance].isAutoReverse ? 0:5));;

    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,width, self.frame.size.height);
}


@end
