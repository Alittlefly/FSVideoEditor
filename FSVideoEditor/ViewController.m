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



@interface ViewController ()

@end

@implementation ViewController

-(void)viewDidLoad{
    [super viewDidLoad];

}

- (IBAction)beginCreat:(id)sender {
    FSToolController *toolController = [[FSToolController alloc] init];
    FSAnimationNavController *nav = [[FSAnimationNavController alloc] initWithRootViewController:toolController];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
