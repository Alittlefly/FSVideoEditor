//
//  FSShortVideoRecorderController.m
//  7nujoom
//
//  Created by 王明 on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSShortVideoRecorderController.h"
#import "FSShortVideoRecorderView.h"

@interface FSShortVideoRecorderController ()<FSShortVideoRecorderViewDelegate>

@property (nonatomic, strong) FSShortVideoRecorderView *recorderView;

@end

@implementation FSShortVideoRecorderController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _recorderView = [[FSShortVideoRecorderView alloc] initWithFrame:self.view.bounds];
    _recorderView.delegate =self;
    [self.view addSubview:_recorderView];
    
    
}

- (void)backClik {
}

- (void)dealloc {
    //_recorderView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];

}

#pragma mark - FSShortVideoRecorderViewDelegate 

- (void)FSShortVideoRecorderViewQuitRecorderView {
    [self.navigationController popViewControllerAnimated:YES];

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
