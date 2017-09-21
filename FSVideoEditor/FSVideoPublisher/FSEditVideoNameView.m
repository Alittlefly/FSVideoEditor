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
#import <AVFoundation/AVFoundation.h>
#import "FSAddChallengeControl.h"


@interface FSEditVideoNameView()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textFile;

@property (nonatomic, strong) UIView *lineView;
//@property (nonatomic, strong) UIButton *addChallengeButton;
@property (nonatomic, strong) FSAddChallengeControl *addChallengeControl;
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
    _textFile = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 25)];
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
    _textFile.adjustsFontSizeToFitWidth = NO;
    [self addSubview:_textFile];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_textFile.frame), self.frame.size.width, 1)];
    _lineView.layer.shadowColor = [UIColor blackColor].CGColor;
    _lineView.layer.shadowOffset = CGSizeMake(1, 1);
    _lineView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_lineView];
    
    NSString *saveText = [NSString stringWithFormat:@"%@",[FSShortLanguage CustomLocalizedStringFromTable:@"SaveInGallery"]];
    CGSize size = [saveText boundingRectWithSize:CGSizeMake(999, 27) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size;
    _saveToPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (_isSave) {
        [_saveToPhotoButton setImage:[UIImage imageNamed:@"save_photo_selected"] forState:UIControlStateNormal];
        
    }
    else {
        [_saveToPhotoButton setImage:[UIImage imageNamed:@"save_photo_unselected"] forState:UIControlStateNormal];
    }
    CGFloat width = size.width+_saveToPhotoButton.imageView.image.size.width + 5;
    _saveToPhotoButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 0 : self.frame.size.width-width, self.frame.size.height-27, width, 27);
    _saveToPhotoButton.backgroundColor = [UIColor clearColor];
    [_saveToPhotoButton setTitle:saveText forState:UIControlStateNormal];
    [_saveToPhotoButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_saveToPhotoButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_saveToPhotoButton setContentHorizontalAlignment:(UIControlContentHorizontalAlignmentLeft)];
    [_saveToPhotoButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
    [_saveToPhotoButton.titleLabel setShadowOffset:CGSizeMake(1, 1)];
    [_saveToPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    

    [_saveToPhotoButton addTarget:self action:@selector(saveToPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveToPhotoButton];
    
    _addChallengeControl = [[FSAddChallengeControl alloc] initWithFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? self.frame.size.width-70 : 0, self.frame.size.height-27, 70, 27)];
    _addChallengeControl.maxWidth = self.frame.size.width - _saveToPhotoButton.frame.size.width;
    _addChallengeControl.backgroundColor = [UIColor clearColor];
    _addChallengeControl.layer.cornerRadius = 2;
    _addChallengeControl.layer.borderColor = [UIColor whiteColor].CGColor;
    _addChallengeControl.layer.borderWidth = 0.5;
    _addChallengeControl.layer.masksToBounds = YES;
    _addChallengeControl.layer.shadowColor = [UIColor blackColor].CGColor;
    _addChallengeControl.layer.shadowOffset = CGSizeMake(1, 1);
    if (_draftInfo.challenge) {
        _isHasChallenge = YES;
        [_addChallengeControl setLeftImage:[FSPublishSingleton sharedInstance].isAutoReverse ? [UIImage imageNamed:@"delete_challenge"]:[UIImage imageNamed:@"#"] title:_draftInfo.challenge.challengeName rightImage:[FSPublishSingleton sharedInstance].isAutoReverse ? [UIImage imageNamed:@"#"]:[UIImage imageNamed:@"delete_challenge"]];
    }
    else {
        _isHasChallenge = NO;
        [_addChallengeControl setLeftImage:[FSPublishSingleton sharedInstance].isAutoReverse ? nil:[UIImage imageNamed:@"white#"] title:[FSShortLanguage CustomLocalizedStringFromTable:@"AddHashtag"] rightImage:[FSPublishSingleton sharedInstance].isAutoReverse ? [UIImage imageNamed:@"white#"]:nil];
    }
    
    [_addChallengeControl addTarget:self action:@selector(addChallenge) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addChallengeControl];
}

- (void)addChallenge {
    if (_isHasChallenge) {
        _draftInfo.challenge = nil;
        _isHasChallenge = NO;
        [_addChallengeControl setLeftImage:[FSPublishSingleton sharedInstance].isAutoReverse ? nil:[UIImage imageNamed:@"white#"] title:[FSShortLanguage CustomLocalizedStringFromTable:@"AddHashtag"] rightImage:[FSPublishSingleton sharedInstance].isAutoReverse ? [UIImage imageNamed:@"white#"]:nil];

        if ([self.delegate respondsToSelector:@selector(FSEditVideoNameViewRemoveChallenge)]) {
            [self.delegate FSEditVideoNameViewRemoveChallenge];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(FSEditVideoNameViewAddChallenge)]) {
            [self.delegate FSEditVideoNameViewAddChallenge];
        }
    }
    
}

- (void)updateChallengeName:(NSString *)name {
    _isHasChallenge = YES;
    [_addChallengeControl setLeftImage:[FSPublishSingleton sharedInstance].isAutoReverse ? [UIImage imageNamed:@"delete_challenge"]:[UIImage imageNamed:@"#"] title:name rightImage:[FSPublishSingleton sharedInstance].isAutoReverse ? [UIImage imageNamed:@"#"]:[UIImage imageNamed:@"delete_challenge"]];
}

- (void)saveToPhoto {
    if (!_isSave) {
        if (!([self canUserPickVideosFromPhotoLibrary] && [self canUserPickPhotosFromPhotoLibrary])) {
            NSString *message = [FSShortLanguage CustomLocalizedStringFromTable:@"MessageNoAccess"];

            FSAlertView *alert = [[FSAlertView alloc] init];
            [alert showWithMessage:message];
            return;
        }
    }
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
    if (textField.text.length >= 40 && string.length > 0) {
        textField.text = [textField.text substringToIndex:40];
        FSAlertView *alert = [[FSAlertView alloc] init];
        [alert showWithMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"MaxLetterLimit"]];
        return NO;
    }
    return YES;
}

- (void)hiddenKeyBorde {
    if ([self.delegate respondsToSelector:@selector(FSEditVideoNameViewEditVideoTitle:)]) {
        [self.delegate FSEditVideoNameViewEditVideoTitle:self.textFile.text];
    }
    [self.textFile resignFirstResponder];
}

#pragma mark - 相册文件选取相关
// 相册是否可用
- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary];
}


// 是否可以在相册中选择视频
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self cameraSupportsMedia:( NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}


// 是否可以在相册中选择视频
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self cameraSupportsMedia:( NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

// 判断是否支持某种多媒体类型：拍照，视频
- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0){
        NSLog(@"Media type is empty.");
        return NO;
    }
    NSArray *availableMediaTypes =[UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL*stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

@end
