//
//  FSMusicSelectController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicListController.h"
#import "FSVideoEditorCommenData.h"
#import "FSMusicCell.h"
#import "FSMusicListView.h"
#import "FSShortVideoRecorderController.h"
#import "FSMusicSever.h"

@interface FSMusicListController ()<FSMusicListViewDelegate,FSMusicSeverDelegate>
{
    FSMusicSever *_sever;
}
@property(nonatomic,strong)FSMusicListView *musicListView;
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)UILabel *titlelabel;
@end

@implementation FSMusicListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 20,CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [_contentView setBackgroundColor:[UIColor whiteColor]];
    [_contentView.layer setCornerRadius:5.0];
    [_contentView.layer setMasksToBounds:YES];
    [self.view addSubview:_contentView];
    
     _titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.view.bounds), 34)];
    [_titlelabel setTextColor:FSHexRGB(0x010a12)];
    [_titlelabel setTextAlignment:(NSTextAlignmentCenter)];
    [_titlelabel setFont:[UIFont systemFontOfSize:15.0]];
    [_titlelabel setText:_musicType.typeName];
    [_contentView addSubview:_titlelabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 54, CGRectGetWidth(_contentView.frame), 1.0)];
    [line setBackgroundColor:FSHexRGB(0xe5e5e5)];
    [_contentView addSubview:line];
    
    _musicListView = [[FSMusicListView alloc] initWithFrame:CGRectMake(0, 55, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 75)];
    [_musicListView setDelegate:self];
    [_contentView addSubview:_musicListView];
    
    
    UIButton *backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [backButton setFrame:CGRectMake(10, 10, 34, 34)];
    [backButton setBackgroundColor:[UIColor redColor]];
    [backButton addTarget:self action:@selector(outNav) forControlEvents:(UIControlEventTouchUpInside)];
    [_contentView addSubview:backButton];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
     _sever = [FSMusicSever new];
    [_sever setDelegate:self];
    [_sever getMusicListWithType:3];//musicType.typeId];
    [_musicListView showLoading:YES];
}
-(void)setMusicType:(FSMusicType *)musicType{
     _musicType = musicType;
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
//    [_contentView setFrame:self.view.bounds];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [_musicListView setMusics:_musiceList];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_musicListView stopPlayCurrentMusic];
}
-(void)musicListWouldUseMusic:(FSMusic *)music musicPath:(NSString *)musicPath{
    FSShortVideoRecorderController *recoder = [[FSShortVideoRecorderController alloc] init];
    recoder.musicFilePath = musicPath;
    [self.navigationController pushViewController:recoder animated:YES];
}
-(void)musicListWouldShowDetail:(FSMusic *)music{
    if ([self.delegate respondsToSelector:@selector(musicListWouldShowDetail:)]) {
        [self.delegate musicListWouldShowDetail:music];
    }
}
#pragma mark - 
-(void)musicSeverGetMusics:(NSArray<FSMusic *> *)musics{
    [_musicListView setMusics:musics];
    [_musicListView showLoading:NO];
}
-(void)musicSeverGetCollectedMusics:(NSArray<FSMusic *> *)musics{
    [_musicListView setMusics:musics];
}
-(void)musicSeverGetFaild{
    [_musicListView showLoading:NO];
}
-(void)outNav{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
