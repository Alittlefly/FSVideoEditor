//
//  ViewController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "ViewController.h"
#import "FSToolController.h"
#import "FSAnimationNavController.h"
#import "FSLoginServer.h"
#import "FSAlertView.h"
#import "FSEditorLoading.h"

@interface ViewController ()<UITextFieldDelegate, FSLoginServerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recorderButton;
@property (weak, nonatomic) IBOutlet UITextField *uidTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (copy, nonatomic) NSString *uid;
@property (copy, nonatomic) NSString *password;

@property (strong, nonatomic) FSLoginServer *loginServer;

@property (nonatomic, strong) FSEditorLoading *loading;
 
@end

@implementation ViewController

-(FSEditorLoading *)loading{
    if (!_loading) {
        _loading = [[FSEditorLoading alloc] initWithFrame:self.view.bounds];
    }
    return _loading;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    CAGradientLayer *bgGradientLayer = [CAGradientLayer layer];
    bgGradientLayer.colors = @[(__bridge id)FSHexRGB(0x000000).CGColor, (__bridge id)FSHexRGB(0x2D062D).CGColor];
    //gradientLayer.locations = @[@0.0];
    bgGradientLayer.startPoint = CGPointMake(0, 0);
    bgGradientLayer.endPoint = CGPointMake(0, 1.0);
    bgGradientLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgGradientLayer atIndex:0];

    _uid = [[NSUserDefaults standardUserDefaults] valueForKey:@"UID"];
    _password = [[NSUserDefaults standardUserDefaults] valueForKey:@"Password"];
    
    if (_uid == nil || _uid.length == 0) {
        self.recorderButton.hidden = YES;
        self.logoutButton.hidden = YES;
        
        self.uidTextField.hidden = NO;
        self.passwordTextField.hidden = NO;
        self.loginButton.hidden = NO;
        [self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];

    }
    else {
        self.recorderButton.hidden = NO;
        self.logoutButton.hidden = NO;
        
        self.uidTextField.hidden = YES;
        self.passwordTextField.hidden = YES;
        self.loginButton.hidden = YES;
        [self.logoutButton setTitle:NSLocalizedString(@"logout", nil) forState:UIControlStateNormal];
    }
    
    UIView *uidView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    uidView.backgroundColor = [UIColor clearColor];
    UIImageView *uidImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phone-number"]];
    uidImageView.frame = CGRectMake(5, 5, 20, 20);
    [uidView addSubview:uidImageView];
    
    self.uidTextField.leftView = uidView;
    self.uidTextField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
    self.uidTextField.delegate = self;
    self.uidTextField.placeholder = NSLocalizedString(@"Account",nil);
    self.uidTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Account",nil) attributes:@{NSForegroundColorAttributeName:FSHexRGBAlpha(0xF5F5F5, 0.5)}];

    
    UIView *passwordView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    passwordView.backgroundColor = [UIColor clearColor];
    UIImageView *passwordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password"]];
    passwordImageView.frame = CGRectMake(5, 5, 20, 20);
    [passwordView addSubview:passwordImageView];

    self.passwordTextField.leftView = passwordView;
    self.passwordTextField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
    self.passwordTextField.delegate = self;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.placeholder = NSLocalizedString(@"Password",nil);
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Password",nil) attributes:@{NSForegroundColorAttributeName:FSHexRGBAlpha(0xF5F5F5, 0.5)}];
    
    [self.logoutButton setTitleColor:FSHexRGB(0x00FFEF) forState:UIControlStateNormal];
    
    [self.loginButton setTitleColor:FSHexRGB(0x00FFEF) forState:UIControlStateNormal];
    self.loginButton.frame = CGRectMake(CGRectGetMinX(self.passwordTextField.frame), CGRectGetMaxY(self.passwordTextField.frame)+20, CGRectGetWidth(self.passwordTextField.frame), CGRectGetHeight(self.passwordTextField.frame));
    self.loginButton.layer.cornerRadius = self.loginButton.frame.size.height/2;
    self.loginButton.layer.masksToBounds = YES;
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)FSHexRGB(0x07FDFC).CGColor, (__bridge id)FSHexRGB(0xEC1DF9).CGColor];
    //gradientLayer.locations = @[@0.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1.0, 0);
    gradientLayer.frame = self.loginButton.bounds;
    [self.loginButton.layer addSublayer:gradientLayer];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *country = [[NSUserDefaults standardUserDefaults] valueForKey:@"Country"];
    
    if (country == nil || country.length == 0) {
        [self showChooseCountryView];
    }
    
}

- (void)showChooseCountryView {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"选择国家" delegate:self cancelButtonTitle:@"tr" otherButtonTitles:@"ar", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NSUserDefaults standardUserDefaults] setValue:@"tr" forKey:@"Country"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setValue:@"ar" forKey:@"Country"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    if (self.uidTextField.hidden == NO) {
        [self.uidTextField resignFirstResponder];
        [self.passwordTextField resignFirstResponder];
    }
}

- (IBAction)beginCreat:(id)sender {
    FSToolController *toolController = [[FSToolController alloc] init];
    FSAnimationNavController *nav = [[FSAnimationNavController alloc] initWithRootViewController:toolController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)logoutClick:(id)sender {
    self.recorderButton.hidden = YES;
    self.logoutButton.hidden = YES;
    
    self.uidTextField.hidden = NO;
    self.passwordTextField.hidden = NO;
    self.loginButton.hidden = NO;
    
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"UID"];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"Password"];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"nickName"];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"loginKey"];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"Country"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    //[self showMessage:NSLocalizedString(@"", nil)];
}

- (IBAction)loginClick:(id)sender {
    NSString *country = [[NSUserDefaults standardUserDefaults] valueForKey:@"Country"];
    
    if (country == nil || country.length == 0) {
        [self showChooseCountryView];
        return;
    }
    
    if (self.uidTextField.text.length == 0) {
        [self showMessage:NSLocalizedString(@"LoginFailed", nil)];
        return;
    }
    
    if (self.passwordTextField.text.length == 0) {
        [self showMessage:NSLocalizedString(@"BadPassword", nil)];
        return;
    }
    
    [self.view addSubview:self.loading];
    [self.loading loadingViewShow];
    
    if (!_loginServer) {
        _loginServer = [[FSLoginServer alloc] init];
        _loginServer.delegate  = self;
    }
    
    [_loginServer loginWithUid:self.uidTextField.text password:self.passwordTextField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -  FSLoginServerDelegate
- (void)FSLoginServerSucceed:(id)objec {
    [self.loading loadingViewhide];
    
    
    NSDictionary *dataInfo = [objec objectForKey:@"dataInfo"];
    
    [[NSUserDefaults standardUserDefaults] setValue:[dataInfo objectForKey:@"loginName"] forKey:@"UID"];
    [[NSUserDefaults standardUserDefaults] setValue:self.passwordTextField.text forKey:@"Password"];
    [[NSUserDefaults standardUserDefaults] setValue:[dataInfo objectForKey:@"nickName"] forKey:@"nickName"];
    [[NSUserDefaults standardUserDefaults] setValue:[dataInfo objectForKey:@"loginKey"] forKey:@"loginKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];


    self.recorderButton.hidden = NO;
    self.logoutButton.hidden = NO;
    
    self.uidTextField.hidden = YES;
    self.passwordTextField.hidden = YES;
    self.loginButton.hidden = YES;
}

- (void)FSLoginServerFaild:(NSError *)error {
    [self.loading loadingViewhide];
    [self showMessage:NSLocalizedString(@"LoginFailed", nil)];
}

- (void)showMessage:(NSString *)message {
    FSAlertView *alertView = [[FSAlertView alloc] init];
    [alertView showWithMessage:message];
}

@end
