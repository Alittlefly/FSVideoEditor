//
//  FSEditVideoNameView.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSEditVideoNameView.h"
#import "FSShortLanguage.h"

@interface FSEditVideoNameView()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textFile;

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *addChallengeButton;
@property (nonatomic, strong) UIButton *addFriendsButton;
@property (nonatomic, strong) UIButton *saveToPhotoButton;
@property (nonatomic, assign) BOOL isSave;
@property (nonatomic, assign) BOOL isHasChallenge;

@end

@implementation FSEditVideoNameView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _isSave = NO;

        [self initBaseUI];
    }
    return self;
}

- (void)initBaseUI {
    _textFile = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    _textFile.backgroundColor = [UIColor clearColor];
    _textFile.placeholder = [FSShortLanguage CustomLocalizedStringFromTable:@"EnterTitle"];//NSLocalizedString(@"EnterTitle", nil);
    _textFile.textColor = [UIColor whiteColor];
    _textFile.returnKeyType = UIReturnKeyDone;
    _textFile.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_textFile.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    _textFile.delegate = self;
    [self addSubview:_textFile];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_textFile.frame), self.frame.size.width, 1)];
    _lineView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_lineView];
    
    _addChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addChallengeButton.frame = CGRectMake(0, CGRectGetMaxY(_lineView.frame)+15, 70, 27);
    _addChallengeButton.backgroundColor = [UIColor clearColor];
    _addChallengeButton.layer.cornerRadius = 2;
    _addChallengeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _addChallengeButton.layer.borderWidth = 0.5;
    _addChallengeButton.layer.masksToBounds = YES;
    [_addChallengeButton setTitle:[NSString stringWithFormat:@"#%@",[FSShortLanguage CustomLocalizedStringFromTable:@"AddHashtag"]] forState:UIControlStateNormal];
    [_addChallengeButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
    _addChallengeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_addChallengeButton addTarget:self action:@selector(addChallenge) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addChallengeButton];
    
    _saveToPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveToPhotoButton.frame = CGRectMake(self.frame.size.width-100, CGRectGetMaxY(_lineView.frame)+15, 100, 27);
    _saveToPhotoButton.backgroundColor = [UIColor clearColor];
    [_saveToPhotoButton setTitle:[NSString stringWithFormat:@"#%@",[FSShortLanguage CustomLocalizedStringFromTable:@"SaveInGallery"]] forState:UIControlStateNormal];
    [_saveToPhotoButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
    [_saveToPhotoButton setTitleColor:_isSave?[UIColor redColor]:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveToPhotoButton addTarget:self action:@selector(saveToPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveToPhotoButton];
    //_saveToPhotoButton.hidden = YES;
}

- (void)addChallenge {
    if (_isHasChallenge) {
        _isHasChallenge = NO;
        [_addChallengeButton setTitle:[NSString stringWithFormat:@"#%@",[FSShortLanguage CustomLocalizedStringFromTable:@"AddHashtag"]] forState:UIControlStateNormal];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(FSEditVideoNameViewAddChallenge)]) {
            [self.delegate FSEditVideoNameViewAddChallenge];
        }
    }
    
}

- (void)updateChallengeName:(NSString *)name {
    _isHasChallenge = YES;
    [_addChallengeButton setTitle:[NSString stringWithFormat:@"#%@ X",name] forState:UIControlStateNormal];

}

- (void)saveToPhoto {
    if ([self.delegate respondsToSelector:@selector(FSEditVideoNameViewSaveToPhotoLibrary:)]) {
        [self.delegate FSEditVideoNameViewSaveToPhotoLibrary:NO];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(FSEditVideoNameViewEditVideoTitle:)]) {
        [self.delegate FSEditVideoNameViewEditVideoTitle:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textFile resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(FSEditVideoNameViewEditVideoTitle:)]) {
        [self.delegate FSEditVideoNameViewEditVideoTitle:textField.text];
    }
    return YES;
}

- (void)hiddenKeyBorde {
    [self.textFile resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(FSEditVideoNameViewEditVideoTitle:)]) {
        [self.delegate FSEditVideoNameViewEditVideoTitle:self.textFile.text];
    }
}

@end
