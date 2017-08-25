//
//  FSEditVideoNameView.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSEditVideoNameView.h"
#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"
#import "FSAlertView.h"

@interface FSEditVideoNameView()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textFile;

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *addChallengeButton;
@property (nonatomic, strong) UIButton *addFriendsButton;
@property (nonatomic, strong) UIButton *saveToPhotoButton;
@property (nonatomic, assign) BOOL isSave;
@property (nonatomic, assign) BOOL isHasChallenge;
@property (nonatomic, strong) FSDraftInfo *draftInfo;

@end

@implementation FSEditVideoNameView

- (instancetype)initWithFrame:(CGRect)frame draftInfo:(FSDraftInfo *)draftInfo {
    if (self = [super initWithFrame:frame]) {
        _draftInfo = draftInfo;
        _isSave = draftInfo.vSaveToAlbum;

        [self initBaseUI];
    }
    return self;
}

- (void)initBaseUI {
    _textFile = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    _textFile.backgroundColor = [UIColor clearColor];
    _textFile.textAlignment = [FSPublishSingleton sharedInstance].isAutoReverse ? NSTextAlignmentRight : NSTextAlignmentLeft;
    _textFile.placeholder = [FSShortLanguage CustomLocalizedStringFromTable:@"EnterTitle"];//NSLocalizedString(@"EnterTitle", nil);
    if (_draftInfo.vTitle) {
        _textFile.text = _draftInfo.vTitle;
    }
    _textFile.textColor = [UIColor whiteColor];
    _textFile.returnKeyType = UIReturnKeyDone;
    _textFile.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_textFile.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    _textFile.delegate = self;
    [self addSubview:_textFile];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_textFile.frame), self.frame.size.width, 1)];
    _lineView.layer.shadowColor = [UIColor blackColor].CGColor;
    _lineView.layer.shadowOffset = CGSizeMake(1, 1);
    _lineView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_lineView];
    
    _addChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addChallengeButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? self.frame.size.width-70 : 0, CGRectGetMaxY(_lineView.frame)+15, 70, 27);
    _addChallengeButton.backgroundColor = [UIColor clearColor];
    _addChallengeButton.layer.cornerRadius = 2;
    _addChallengeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _addChallengeButton.layer.borderWidth = 0.5;
    _addChallengeButton.layer.masksToBounds = YES;
    _addChallengeButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _addChallengeButton.layer.shadowOffset = CGSizeMake(1, 1);
    [_addChallengeButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_addChallengeButton.titleLabel setShadowOffset:CGSizeMake(1, 1)];
    [_addChallengeButton setTitle:[NSString stringWithFormat:@"#%@",[FSShortLanguage CustomLocalizedStringFromTable:@"AddHashtag"]] forState:UIControlStateNormal];
    [_addChallengeButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [_addChallengeButton addTarget:self action:@selector(addChallenge) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addChallengeButton];
    //_addChallengeButton.hidden = YES;
    
    _saveToPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveToPhotoButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 0 : self.frame.size.width-100, CGRectGetMaxY(_lineView.frame)+15, 100, 27);
    _saveToPhotoButton.backgroundColor = [UIColor clearColor];
    [_saveToPhotoButton setTitle:[NSString stringWithFormat:@"%@",[FSShortLanguage CustomLocalizedStringFromTable:@"SaveInGallery"]] forState:UIControlStateNormal];
    [_saveToPhotoButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_saveToPhotoButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_saveToPhotoButton.titleLabel setShadowOffset:CGSizeMake(1, 1)];
    [_saveToPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (_isSave) {
        [_saveToPhotoButton setImage:[UIImage imageNamed:@"save_photo_selected"] forState:UIControlStateNormal];

    }
    else {
        [_saveToPhotoButton setImage:[UIImage imageNamed:@"save_photo_unselected"] forState:UIControlStateNormal];
    }
    [_saveToPhotoButton addTarget:self action:@selector(saveToPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveToPhotoButton];
    //_saveToPhotoButton.hidden = YES;
    
    [self updateChallengeButtonFrame];
    
}

- (void)updateChallengeButtonFrame {
    CGFloat maxWidth = self.frame.size.width - _saveToPhotoButton.frame.size.width-5;
    CGSize size = [_addChallengeButton.titleLabel.text boundingRectWithSize:CGSizeMake(999, 27) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]} context:nil].size;
    CGFloat width = size.width;
    if (width > maxWidth) {
        width = maxWidth;
    }

    _addChallengeButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? self.frame.size.width - width : _addChallengeButton.frame.origin.x, _addChallengeButton.frame.origin.y, width, _addChallengeButton.frame.size.height);
}

- (void)addChallenge {
    if (_isHasChallenge) {
        [FSPublishSingleton sharedInstance].chooseChallenge = nil;
        _isHasChallenge = NO;
        [_addChallengeButton setTitle:[NSString stringWithFormat:@"#%@",[FSShortLanguage CustomLocalizedStringFromTable:@"AddHashtag"]] forState:UIControlStateNormal];
        [self updateChallengeButtonFrame];
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

    [self updateChallengeButtonFrame];
}

- (void)saveToPhoto {
    _isSave = !_isSave;
    
    if (_isSave) {
        [_saveToPhotoButton setImage:[UIImage imageNamed:@"save_photo_selected"] forState:UIControlStateNormal];
    }
    else {
        [_saveToPhotoButton setImage:[UIImage imageNamed:@"save_photo_unselected"] forState:UIControlStateNormal];
    }
    if ([self.delegate respondsToSelector:@selector(FSEditVideoNameViewSaveToPhotoLibrary:)]) {
        [self.delegate FSEditVideoNameViewSaveToPhotoLibrary:_isSave];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length == 40 && string.length > 0) {
        FSAlertView *alert = [[FSAlertView alloc] init];
        [alert showWithMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"MaxLetterLimit"]];
        return NO;
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
