//
//  FSAddChallengeController.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSAddChallengeController.h"
#import "FSVideoEditorCommenData.h"
#import "FSChallengeDataServer.h"
#import "FSEditorLoading.h"
#import "FSShortLanguage.h"
#import "FSAlertView.h"
#import "FSPublishSingleton.h"
#import "FSAddChallengeTextField.h"

@interface FSAddChallengeController ()<UITextViewDelegate, UITextFieldDelegate, FSChallengeDataServerDelegate>

@property (nonatomic, strong) FSAddChallengeTextField *nameTextField;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UILabel *maxWordsLabel;
@property (nonatomic, strong) UIButton *commitButton;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property(nonatomic,strong)FSEditorLoading *loading;

@property (nonatomic, strong) FSChallengeDataServer *challengeServer;

@end

@implementation FSAddChallengeController

-(FSEditorLoading *)loading{
    if (!_loading) {
        _loading = [[FSEditorLoading alloc] initWithFrame:self.view.bounds];
    }
    return _loading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = FSHexRGB(0xFFFFFF);
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse?self.view.frame.size.width-30-15 : 15, 25, 30, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"addChallenge_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    if ([FSPublishSingleton sharedInstance].isAutoReverse) {
        backButton.transform = CGAffineTransformMakeScale(-1, 1);
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, 30, 100, 24)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = FSHexRGB(0x292929);
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"AddHashtag"];
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake((self.view.frame.size.width-titleLabel.frame.size.width)/2, 30, titleLabel.frame.size.width, 24);
    [self.view addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(![FSPublishSingleton sharedInstance].isAutoReverse ? CGRectGetMinX(titleLabel.frame)-20 : CGRectGetMaxX(titleLabel.frame), 32, 20, 20)];
    imageView.image = [UIImage imageNamed:@"#"];
    [self.view addSubview:imageView];
    
    [self createBaseUI];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClick)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self tapGestureClick];
}

- (void)createBaseUI {
    _nameTextField = [[FSAddChallengeTextField alloc] initWithFrame:CGRectMake(15, 88, self.view.frame.size.width-30, 50)];
    _nameTextField.backgroundColor = FSHexRGB(0xF1F1F2);
    _nameTextField.layer.cornerRadius = 2;
    _nameTextField.layer.masksToBounds = YES;

    UIImageView *leftView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 14, 14)];
    leftView.image = [UIImage imageNamed:@"#"];
    if ([FSPublishSingleton sharedInstance].isAutoReverse) {
        _nameTextField.rightView = leftView;
        _nameTextField.rightViewMode = UITextFieldViewModeAlways;
    }
    else {
        _nameTextField.leftView = leftView;
        _nameTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    
    _nameTextField.textAlignment = [FSPublishSingleton sharedInstance].isAutoReverse ? NSTextAlignmentRight : NSTextAlignmentLeft;
    _nameTextField.placeholder = [FSShortLanguage CustomLocalizedStringFromTable:@"EnterChallenge"];
    _nameTextField.text = _challengeName.length > 50 ? [_challengeName substringToIndex:50]:_challengeName;
    _nameTextField.font = [UIFont systemFontOfSize:14];
    _nameTextField.delegate = self;
    [self.view addSubview:_nameTextField];
    
    _contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_nameTextField.frame)+10, self.view.frame.size.width-30, 140)];
    _contentTextView.backgroundColor = FSHexRGB(0xF1F1F2);
    _contentTextView.layer.cornerRadius = 2;
    _contentTextView.layer.masksToBounds = YES;
    _contentTextView.font = [UIFont systemFontOfSize:13];
    _contentTextView.delegate = self;
    _contentTextView.textAlignment = [FSPublishSingleton sharedInstance].isAutoReverse ? NSTextAlignmentRight : NSTextAlignmentLeft;
    [self.view addSubview:_contentTextView];
    
    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, _contentTextView.frame.size.width-20, 18)];
    _placeholderLabel.backgroundColor = [UIColor clearColor];
    _placeholderLabel.textAlignment = [FSPublishSingleton sharedInstance].isAutoReverse ? NSTextAlignmentRight : NSTextAlignmentLeft;
    _placeholderLabel.textColor = FSHexRGB(0x796565);
    _placeholderLabel.font = [UIFont systemFontOfSize:13];
    _placeholderLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"ChallengeDescribe"];
    [_contentTextView addSubview:_placeholderLabel];
    
    _maxWordsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_contentTextView.frame)+10, CGRectGetWidth(_contentTextView.frame), 16)];
    _maxWordsLabel.backgroundColor = [UIColor clearColor];
    _maxWordsLabel.textAlignment = [FSPublishSingleton sharedInstance].isAutoReverse ? NSTextAlignmentLeft : NSTextAlignmentRight;
    _maxWordsLabel.textColor = FSHexRGB(0x796565);
    _maxWordsLabel.font = [UIFont systemFontOfSize:11];
    NSString *maxWordsCount = [FSShortLanguage CustomLocalizedStringFromTable:@"MaxWordsCount"];
    maxWordsCount = [maxWordsCount stringByReplacingOccurrencesOfString:@"(0)" withString:@"140"];
    _maxWordsLabel.text = maxWordsCount;
    [self.view addSubview:_maxWordsLabel];
    
    _commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commitButton.frame = CGRectMake(60, CGRectGetMaxY(_contentTextView.frame)+56, self.view.frame.size.width-120, 44);
    _commitButton.layer.cornerRadius = 5;
    _commitButton.layer.masksToBounds = YES;
    _commitButton.backgroundColor = FSHexRGB(0x0BC2C6);
    [_commitButton setTitleColor:FSHexRGB(0xFFFFFF) forState:UIControlStateNormal];
    [_commitButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Confirm"] forState:UIControlStateNormal];
    [_commitButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_commitButton addTarget:self action:@selector(commitNewChallenge) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_commitButton];
}

- (void)backClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapGestureClick {
    [self.nameTextField resignFirstResponder];
    [self.contentTextView resignFirstResponder];
}

- (void)commitNewChallenge {
    NSString *nameText = [_nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (nameText.length == 0) {
        return;
    }
    else if (nameText.length > 50) {
        [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"MaxLetterLimit"]];
        return;
    }

    [self.view addSubview:self.loading];
    [self.loading loadingViewShow];
    
    if (!_challengeServer) {
        _challengeServer = [[FSChallengeDataServer alloc] init];
        _challengeServer.delegate = self;
    }
    FSChallengeModel *model = [[FSChallengeModel alloc] init];
    model.name = self.nameTextField.text;
    model.content = self.contentTextView.text;
    [_challengeServer addNewChallenge:model];
}

- (void)showMessage:(NSString *)message {
    FSAlertView *alertView = [[FSAlertView alloc] init];
    [alertView showWithMessage:message];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
//    if (textField.text.length == 0) {
//        textField.placeholder = @"challenge name";
//    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length >= 50 && string.length > 0) {
        textField.text = [textField.text substringToIndex:50];
        [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"MaxLetterLimit"]];
        return NO;
    }
    else {
//        if (textField.text.length == 0 && string.length > 0) {
//            _placeholderLabel.hidden = YES;
//        }
//        else if (textField.text.length == 1 && string.length == 0) {
//            _placeholderLabel.hidden = NO;
//        }
        return YES;
    }
}
#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (textView.text.length >= 140 && text.length > 0) {
        textView.text = [textView.text substringToIndex:140];
        [self showMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"MaxLetterLimit"]];
        return NO;
    }
    else {
        if (textView.text.length == 0 && text.length > 0) {
            _placeholderLabel.hidden = YES;
        }
        else if (textView.text.length == 1 && text.length == 0) {
            _placeholderLabel.hidden = NO;
        }
        return YES;
    }
}

#pragma mark - FSChallengeDataServerDelegate
- (void)FSChallengeDataServerAddChallengeFailed:(NSError *)error {
    [self.loading loadingViewhide];
    
    FSAlertView *alert = [[FSAlertView alloc] init];
    [alert showWithMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"AddChanllengeFailed"]];
    
}

- (void)FSChallengeDataServerAddChallengeSucceed:(FSChallengeModel *)model {
    [self.loading loadingViewhide];

    if ([self.delegate respondsToSelector:@selector(FSAddChallengeControllerNewChallenge:)]) {
        [self.delegate FSAddChallengeControllerNewChallenge:model];
    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)FSChallengeDataServerAddChallengeCode:(NSInteger)code {
    [self.loading loadingViewhide];

    if (code == 6607) {
        FSAlertView *alert = [[FSAlertView alloc] init];
        [alert showWithMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"ChallengeExisted"]];
    }
    else {
        FSAlertView *alert = [[FSAlertView alloc] init];
        [alert showWithMessage:[FSShortLanguage CustomLocalizedStringFromTable:@"AddChanllengeFailed"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
