//
//  FSLocalVideoToolController.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/12/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSLocalVideoToolController.h"
#import "FSLocalVideoController.h"
#import "FSPublishSingleton.h"
#import "FSShortLanguage.h"
#import "FSVideoEditorCommenData.h"

@interface FSLocalVideoToolController ()<FSLocalVideoControllerDelegate>

@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)FSLocalVideoController *localView;
@property(nonatomic, strong) UIButton *editButton;

@end

@implementation FSLocalVideoToolController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 20+FSSafeAreaTopHeight,CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [_contentView setBackgroundColor:[UIColor whiteColor]];
    [_contentView.layer setCornerRadius:5.0];
    [_contentView.layer setMasksToBounds:YES];
    [self.view addSubview:_contentView];
    
    
    NSString *backText = [FSShortLanguage CustomLocalizedStringFromTable:@"Back"];
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0]};
    CGRect newSize = [backText boundingRectWithSize:CGSizeMake(0,MAXFLOAT) options:(NSStringDrawingUsesFontLeading) attributes:dict context:nil];
    CGFloat textW = CGRectGetWidth(newSize);
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setContentHorizontalAlignment:(UIControlContentHorizontalAlignmentCenter)];
    backButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? CGRectGetWidth(_contentView.frame) - textW - 20: 20, 17, textW, 21);
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [backButton setTitle:backText forState:UIControlStateNormal];
    
    [backButton setTitleColor:FSHexRGB(0x73747B) forState:(UIControlStateNormal)];
    [backButton addTarget:self action:@selector(dissmissController) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:backButton];
    
    NSString *chooseMusic = [FSShortLanguage CustomLocalizedStringFromTable:@"UploadVideo"];
    CGRect chooseSize = [chooseMusic boundingRectWithSize:CGSizeMake(0,MAXFLOAT) options:(NSStringDrawingUsesFontLeading) attributes:dict context:nil];
    CGFloat chooseSizeW = CGRectGetWidth(chooseSize);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(_contentView.frame) - chooseSizeW)/2.0, 17, chooseSizeW, 21)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = FSHexRGB(0x020A13);
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = chooseMusic;
    [_contentView addSubview:titleLabel];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *nextText = [FSShortLanguage CustomLocalizedStringFromTable:@"ResetPwdBtnTitle"];
    CGRect nextTextSize = [nextText boundingRectWithSize:CGSizeMake(0,MAXFLOAT) options:(NSStringDrawingUsesFontLeading) attributes:dict context:nil];
    CGFloat nextTextW = CGRectGetWidth(nextTextSize);
    nextButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 20: _contentView.frame.size.width- nextTextW - 20, 17, nextTextW, 21);
    [nextButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"ResetPwdBtnTitle"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [nextButton setTitleColor:FSHexRGB(0xCACACA) forState:(UIControlStateNormal)];
    [_contentView addSubview:nextButton];
    nextButton.enabled = NO;
    _editButton = nextButton;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 54, CGRectGetWidth(_contentView.frame), 1.0)];
    [line setBackgroundColor:FSHexRGB(0xe5e5e5)];
    [_contentView addSubview:line];
    
    if (!_localView) {
        
        _localView = [[FSLocalVideoController alloc] init];
        [self addChildViewController:_localView];
        _localView.delegate = self;
        [_localView.view setFrame:CGRectMake(0, 55, CGRectGetWidth(self.view.bounds), CGRectGetHeight(_contentView.frame)  - 20)];
        [_contentView addSubview:_localView.view];
        
    }
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dissmissController) name:@"kNotificationDeepLinkOrPush" object:nil];

}

- (void)clickButton:(UIButton *)button {
    [_localView enterEditView];
}

- (void)dissmissController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNSNotificationVideoEditToolWillShow object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNSNotificationVideoEditToolDidHide object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kNotificationDeepLinkOrPush" object:nil];
    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

#pragma mark - FSLocalVideoControllerDelegate
- (void)FSLocalVideoControllerDidChooseOneVideo {
    _editButton.enabled = YES;
    [_editButton setTitleColor:FSHexRGB(0x73747B) forState:(UIControlStateNormal)];

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
