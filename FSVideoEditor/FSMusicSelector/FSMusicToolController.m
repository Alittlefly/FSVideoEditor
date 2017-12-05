//
//  FSMusicToolController.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/12/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicToolController.h"
#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"
#import "FSVideoEditorCommenData.h"

@interface FSMusicToolController ()<FSMusicControllerDelegate>

@property(nonatomic,strong)UIView *contentView;

@end

@implementation FSMusicToolController

- (instancetype)init {
    if (self = [super init]) {
        _musicView = [[FSMusicController alloc] init];
        [_musicView setDelegate:self];
        [self addChildViewController:_musicView];
        [_musicView.view setFrame:CGRectMake(0, 55, CGRectGetWidth(self.view.bounds), CGRectGetHeight(_contentView.frame)  - 20)];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 20,CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [_contentView setBackgroundColor:[UIColor whiteColor]];
    [_contentView.layer setCornerRadius:5.0];
    [_contentView.layer setMasksToBounds:YES];
    [self.view addSubview:_contentView];
    
    
    NSString *backText = [FSShortLanguage CustomLocalizedStringFromTable:@"Record"];
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
    
    NSString *chooseMusic = [FSShortLanguage CustomLocalizedStringFromTable:@"ChooseMusic"];
    CGRect chooseSize = [chooseMusic boundingRectWithSize:CGSizeMake(0,MAXFLOAT) options:(NSStringDrawingUsesFontLeading) attributes:dict context:nil];
    CGFloat chooseSizeW = CGRectGetWidth(chooseSize);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(_contentView.frame) - chooseSizeW)/2.0, 17, chooseSizeW, 21)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = FSHexRGB(0x020A13);
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = chooseMusic;
    [_contentView addSubview:titleLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 54, CGRectGetWidth(_contentView.frame), 1.0)];
    [line setBackgroundColor:FSHexRGB(0xe5e5e5)];
    [_contentView addSubview:line];
    
        
    [_contentView addSubview:_musicView.view];
        
    
    [self.view setBackgroundColor:[UIColor clearColor]];
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

#pragma mark -
-(UIViewController *)musicControllerWouldShowMusicDetail:(FSMusic *)music{
    
    UIViewController *deatilController = nil;
    
    if ([self.delegate respondsToSelector:@selector(musicDetailControllerWithMusic:)]) {
        deatilController = [self.delegate musicDetailControllerWithMusic:music];
    }
    
    NSAssert(![deatilController isKindOfClass:[UINavigationController class]], @"返回的控制器不能为nav");
    return deatilController;
}

- (void)musicControllerSelectMusic:(NSString *)musicPath music:(FSMusic *)music {
    if ([self.delegate respondsToSelector:@selector(FSMusicToolVCDidSelectedMusic:filePath:)]) {
        [self.delegate FSMusicToolVCDidSelectedMusic:music filePath:musicPath];
    }
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNSNotificationVideoEditToolDidHide object:nil];
    
    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
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
