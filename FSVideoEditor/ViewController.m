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

@interface ViewController ()<UITextFieldDelegate, FSLoginServerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recorderButton;
@property (weak, nonatomic) IBOutlet UITextField *uidTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (copy, nonatomic) NSString *uid;
@property (copy, nonatomic) NSString *password;

@property (strong, nonatomic) FSLoginServer *loginServer;

@property (strong, nonatomic) UIActivityIndicatorView  *activityView;

@end

@implementation ViewController

-(void)viewDidLoad{
    [super viewDidLoad];

    _uid = [[NSUserDefaults standardUserDefaults] valueForKey:@"UID"];
    _password = [[NSUserDefaults standardUserDefaults] valueForKey:@"Password"];
    
    if (_uid == nil || _uid.length == 0) {
        self.recorderButton.hidden = YES;
        self.logoutButton.hidden = YES;
        
        self.uidTextField.hidden = NO;
        self.passwordTextField.hidden = NO;
        self.loginButton.hidden = NO;
    }
    else {
        self.recorderButton.hidden = NO;
        self.logoutButton.hidden = NO;
        
        self.uidTextField.hidden = YES;
        self.passwordTextField.hidden = YES;
        self.loginButton.hidden = YES;
    }
    
    UIView *uidView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    uidView.backgroundColor = [UIColor clearColor];
    UIImageView *uidImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phone-number"]];
    uidImageView.frame = CGRectMake(10, 10, 20, 20);
    [uidView addSubview:uidImageView];
    
    self.uidTextField.leftView = uidView;
    self.uidTextField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
    self.uidTextField.delegate = self;
    
    UIView *passwordView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    passwordView.backgroundColor = [UIColor clearColor];
    UIImageView *passwordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password"]];
    passwordImageView.frame = CGRectMake(10, 10, 20, 20);
    [passwordView addSubview:passwordImageView];

    self.passwordTextField.leftView = passwordView;
    self.passwordTextField.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview现实时机
    self.passwordTextField.delegate = self;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
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
}

- (IBAction)loginClick:(id)sender {
    if (self.uidTextField.text.length == 0) {
        [self showMessage:@"用户名不能为空！"];
        return;
    }
    
    if (self.passwordTextField.text.length == 0) {
        [self showMessage:@"密码不能为空！"];
        return;
    }
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.frame = CGRectMake(0, 0, 100, 100);
        _activityView.center = self.view.center;
        [self.view addSubview:_activityView];
    }
    [_activityView startAnimating];
    
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
    [_activityView stopAnimating];

    self.recorderButton.hidden = NO;
    self.logoutButton.hidden = NO;
    
    self.uidTextField.hidden = YES;
    self.passwordTextField.hidden = YES;
    self.loginButton.hidden = YES;
    
    [[NSUserDefaults standardUserDefaults] setValue:@"uid" forKey:@"UID"];
    [[NSUserDefaults standardUserDefaults] setValue:@"password" forKey:@"Password"];
}

- (void)FSLoginServerFaild:(NSError *)error {
    [_activityView stopAnimating];
    [self showMessage:@"登录失败"];
}

- (void)showMessage:(NSString *)message {
    FSAlertView *alertView = [[FSAlertView alloc] init];
    [alertView showWithMessage:message];
}

@end
