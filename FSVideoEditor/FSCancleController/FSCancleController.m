//
//  FSCancleController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/14.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSCancleController.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"

@interface FSCancleController ()
@end

@implementation FSCancleController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)initCancleButton{
    if (!_cancleButton) {
        _cancleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49)];
    }
    
    [_cancleButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Cancle"] forState:(UIControlStateNormal)];
    [_cancleButton setBackgroundColor:FSHexRGB(0xffffff)];
    [_cancleButton setTitleColor:FSHexRGB(0x73747B) forState:(UIControlStateNormal)];
    [_cancleButton.layer setShadowOffset:CGSizeMake(0.0, -2.0)];
    [_cancleButton.layer setShadowRadius:3.0];
    [_cancleButton.layer setShadowColor:FSHexRGBAlpha(0x000000,1.0).CGColor];
    [_cancleButton.layer setShadowOpacity:0.1];
    [_cancleButton addTarget:self action:@selector(dissmissController) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_cancleButton];
}
- (void)dissmissController{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
