//
//  FSMusicSearchResultView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/26.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicSearchResultView.h"
#import "FSVideoEditorCommenData.h"
#import "FSMusicCell.h"


@interface FSMusicSearchResultView ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *contentView;
@end

@implementation FSMusicSearchResultView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self  = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self creatSubview:frame];
    }
    return self;
}
-(void)creatSubview:(CGRect)frame{
    if (!_contentView) {
        _contentView = [[UITableView alloc] initWithFrame:self.bounds style:(UITableViewStylePlain)];
        [_contentView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
        [_contentView setSeparatorColor:FSHexRGB(0xe5e5e5)];
        [_contentView setTableFooterView:[UIView new]];
        [_contentView setTableHeaderView:[UIView new]];
        [_contentView setDelegate:self];
        [_contentView setDataSource:self];
    }
    [self addSubview:_contentView];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    if (!_contentView) {
        [self creatSubview:self.bounds];
    }
    [_contentView setFrame:self.bounds];
}
#pragma mark - 
-(void)setMusics:(NSArray *)musics{
    
    _musics = musics;
    
    [_contentView reloadData];
}
#pragma mark - 
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_musics count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FSMusicCell *cell = [FSMusicCell musicCellWithTableView:tableView indexPath:indexPath];
    [cell setMusic:[_musics objectAtIndex:indexPath.row]];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FSMusic *music = [self.musics objectAtIndex:indexPath.row];
    if (music.opend) {
        return 147.0;
    }
    return 107.0;
}

@end
