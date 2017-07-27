//
//  FSChallengeController.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSChallengeController.h"
#import "FSVideoEditorCommenData.h"
#import "FSChallengeCell.h"
#import "FSEditorLoading.h"
#import "FSChallengeDataServer.h"
#import "FSChallengeParam.h"
#import "FSAddChallengeController.h"
#import "FSShortLanguage.h"

@interface FSChallengeController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, FSChallengeDataServerDelegate, FSChallengeCellDelegate, FSAddChallengeControllerDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic,strong)FSEditorLoading *loading;
@property (nonatomic, strong) UIVisualEffectView *effectView;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *searchDataArray;


@property (nonatomic, strong) FSChallengeDataServer *dataServer;

@property (nonatomic, assign) NSInteger pageNum;

@property (nonatomic, assign) BOOL isSearched;

@end

@implementation FSChallengeController

-(FSEditorLoading *)loading{
    if (!_loading) {
        _loading = [[FSEditorLoading alloc] initWithFrame:self.view.bounds];
    }
    return _loading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = FSHexRGBAlpha(0xFFFFFF, 0.7);
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    _effectView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _effectView.alpha = 0.97;
    
    [self.view addSubview:_effectView];
    
    _dataArray = [NSArray array];
    _searchDataArray = [NSArray array];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.backgroundColor =[UIColor clearColor];
    closeButton.frame = CGRectMake(12, 35, 15, 15);
    [closeButton setImage:[UIImage imageNamed:@"challenge_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(backView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, 30, 100, 24)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = FSHexRGB(0x292929);
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"AddHashtag"];
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake((self.view.frame.size.width-titleLabel.frame.size.width)/2, 30, titleLabel.frame.size.width, 24);
    [self.view addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame), 32, 20, 20)];
    imageView.image = [UIImage imageNamed:@"#"];
    [self.view addSubview:imageView];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+33, self.view.frame.size.width-20, 40)];
    _textField.backgroundColor = [UIColor clearColor];
    _textField.layer.borderColor = FSHexRGBAlpha(0x979797, 0.6).CGColor;
    _textField.layer.borderWidth = 1;
    _textField.returnKeyType = UIReturnKeySearch;
    _textField.delegate = self;
    _textField.placeholder = @"输入挑战";
    [self.view addSubview:_textField];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, CGRectGetHeight(_textField.frame))];
    _textField.leftView = paddingView;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_textField.frame)+20, self.view.frame.size.width, self.view.frame.size.height-CGRectGetMaxY(_textField.frame)-20) style:(UITableViewStylePlain)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _dataServer = [[FSChallengeDataServer alloc] init];
    _dataServer.delegate = self;
    [_dataServer requestChallengeDataList:nil isSearch:NO];
    
    [self.view addSubview:self.loading];
    [self.loading loadingViewShow];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)backView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FSChallengeDataServerDelegate
- (void)FSChallengeDataServerSucceed:(NSArray *)array {
    [self.loading loadingViewhide];

    if (_isSearched == NO) {
        _dataArray = nil;
        _dataArray = [NSArray arrayWithArray:array];
    }
    else {
        _searchDataArray = nil;
        if (array.count == 0) {
            FSChallengeModel *model = [[FSChallengeModel alloc] init];
            model.name = self.textField.text;
            
            _searchDataArray = [NSArray arrayWithObject:model];
        }
        else {
            _searchDataArray = [NSArray arrayWithArray:array];

        }
    }

    [_tableView reloadData];
}

- (void)FSChallengeDataServerFailed:(NSError *)error {
    [self.loading loadingViewhide];

}

#pragma mark - FSChallengeCellDelegate
- (void)fsChallengeCellAddNewChallenge:(NSString *)title {
    FSAddChallengeController *addChallengeVC = [[FSAddChallengeController alloc] init];
    addChallengeVC.challengeName = title;
    addChallengeVC.delegate = self;
    [self.navigationController pushViewController:addChallengeVC animated:YES];
}

#pragma mark - FSAddChallengeControllerDelegate
- (void)FSAddChallengeControllerNewChallenge:(FSChallengeModel *)model {
    if ([self.delegate respondsToSelector:@selector(FSChallengeControllerChooseChallenge:)]) {
        [self.delegate FSChallengeControllerChooseChallenge:model];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - textfield
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length == 1 && string.length == 0) {
//        _tableView.hidden = NO;
        _searchDataArray = nil;
        _isSearched = NO;
    }
    else if(textField.text.length == 0 && string.length > 0){
//        _tableView.hidden = YES;
        _isSearched = YES;
    }
    [_tableView reloadData];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [self.view addSubview:self.loading];
    [self.loading loadingViewShow];
    
    _searchDataArray = nil;
    
    FSChallengeParam *param = [[FSChallengeParam alloc] init];
    param.w = textField.text;
    param.no = 0;
    param.size = 10;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:textField.text, @"w", @"1", @"no", @"10", @"size", nil];
    [_dataServer requestChallengeDataList:dic isSearch:YES];
    
    return YES;
}

#pragma mark - tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"Cell";
    FSChallengeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[FSChallengeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.delegate = self;
    }
    
    if (_isSearched == NO) {
        FSChallengeModel *model = [_dataArray objectAtIndex:indexPath.row];
        [cell setChallengeModel:model];
    }
    else {
        FSChallengeModel *model = [_searchDataArray objectAtIndex:indexPath.row];
        [cell setChallengeModel:model];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearched == NO) {
        return _dataArray.count;
    }
    else {
        return _searchDataArray.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_isSearched == NO) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, 20)];
        bgView.backgroundColor = [UIColor clearColor];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, 20)];
        headerLabel.text = @"热门挑战";
        [bgView addSubview:headerLabel];
        
        return bgView;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearched == NO) {
        if (_dataArray.count == 0) {
            return 0;
        }
        else {
            FSChallengeModel *model = [_dataArray objectAtIndex:indexPath.row];
            
            return model.cellHeight;
        }
    }
    else {
        if (_searchDataArray.count == 0) {
            return 0;
        }
        else {
            FSChallengeModel *model = [_searchDataArray objectAtIndex:indexPath.row];
            
            return model.cellHeight;
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return _isSearched == NO ? 20 : 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FSChallengeModel *model = nil;
    if (_isSearched == NO) {
        model = [_dataArray objectAtIndex:indexPath.row];
    }
    else {
        model = [_searchDataArray objectAtIndex:indexPath.row];
    }
    
    if (model.challengeId == 0) {
        [self fsChallengeCellAddNewChallenge:model.name];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(FSChallengeControllerChooseChallenge:)]) {
            [self.delegate FSChallengeControllerChooseChallenge:model];
        }
        [self dismissViewControllerAnimated:NO completion:nil];
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
