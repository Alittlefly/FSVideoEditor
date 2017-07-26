//
//  FSMusicController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/29.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicController.h"
#import "NvsStreamingContext.h"
#import "FSShortVideoRecorderController.h"
#import "FSMusicPlayer.h"
#import "FSMusicSever.h"
#import "FSMusicManager.h"
#import "FSEditorLoading.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"
#import "FSSearchBar.h"
#import "FSMusicHeaderView.h"

@interface FSMusicController ()<UITableViewDelegate,UITableViewDataSource,FSMusicCellDelegate,FSMusicSeverDelegate,UISearchBarDelegate>{
    FSMusic *_music;
    FSMusicSever *_sever;
}
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *musics;
@property(nonatomic,strong)FSEditorLoading *loading;
@property(nonatomic,strong)FSSearchBar *searchBar;

@end

@implementation FSMusicController

-(FSEditorLoading *)loading{
    if (!_loading) {
        _loading = [[FSEditorLoading alloc] initWithFrame:self.view.bounds];
    }
    return _loading;
}
-(NSMutableArray *)musics{
    if (!_musics) {
        
        _musics = [NSMutableArray arrayWithCapacity:0];
    }
    return _musics;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    for(NSInteger index = 0 ;index < 3;index ++){
        FSMusic *music = [[FSMusic alloc] init];
        music.songTitle = @"month";
        music.lastSeconds = 15;
        music.songPic = @"";
        music.songAuthor = @"徐子谦";
        FSMusic *music1 = [[FSMusic alloc] init];
        music1.songTitle = @"wind";
        music1.lastSeconds = 15;
        music1.songPic = @"";
        music1.songAuthor = @"高超";
        FSMusic *music2 = [[FSMusic alloc] init];
        music2.songTitle = @"ugly";
        music2.lastSeconds = 15;
        music2.songPic = @"";
        music2.songAuthor = @"王明";
        FSMusic *music3 = [[FSMusic alloc] init];
        music3.songTitle = @"ugly";
        music3.lastSeconds = 15;
        music3.songPic = @"";
        music3.songAuthor = @"王明";
        [self.musics addObjectsFromArray:@[music,music1,music2,music3]];
    }
    
    
    _searchBar = [[FSSearchBar alloc] initWithFrame:CGRectMake(10, 8, CGRectGetWidth(self.view.bounds) - 20, 28) delegate:self];
    [self.view addSubview:_searchBar];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    [self.view addSubview:_tableView];
    
    FSMusicHeaderView *tableHeader = [[FSMusicHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 228)];

    [_tableView setTableHeaderView:tableHeader];
    [_tableView setTableFooterView:[UIView new]];
    
     _sever = [[FSMusicSever alloc] init];
    [_sever setDelegate:self];
    [_sever getMusicList];
    
    [self.view addSubview:self.loading];
    [self.loading loadingViewShow];
    
    [self initCancleButton];
    
}

#pragma mark -
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"searchBarShouldBeginEditing ");
    [_searchBar setShowCancle:YES];
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [_searchBar setShowCancle:NO];
    return YES;
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"点击取消");
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if([searchBar canResignFirstResponder]){
        [searchBar resignFirstResponder];
    }
    [_searchBar setShowCancle:NO];
    
    NSString *trimText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"要查询的内容是 trimText %@",trimText);
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    [_searchBar setFrame:CGRectMake(10, 8, CGRectGetWidth(self.view.bounds) - 20, 28)];
    
    CGRect tableFrame = CGRectMake(0, CGRectGetMaxY(_searchBar.frame) + 15, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 100);
    [_tableView setFrame:tableFrame];
    
    [self.cancleButton setFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49)];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.musics count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FSMusicCell *cell = [FSMusicCell musicCellWithTableView:tableView indexPath:indexPath];
    [cell setDelegate:self];
    FSMusic *music = [self.musics objectAtIndex:indexPath.row];
    [cell setMusic:music];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FSMusic *music = [self.musics objectAtIndex:indexPath.row];
    
    if (music.opend) {
        return 147.0;
    }
    return 107.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    FSMusic *music = [self.musics objectAtIndex:indexPath.row];
    
    // cell 动画
    [self tableView:tableView updateTableWithMusic:music selectIndexPath:indexPath];
    // 播放
    FSMusicCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    [self playMusic:music playViewCell:cell];
    
}

- (void)stopPlayCurrentMusic {
    for (int i = 0; i < _musics.count; i++) {
        FSMusic *music = [_musics objectAtIndex:i];
        if (music.isPlaying) {
            music.isPlaying = NO;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            FSMusicCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            [cell setIsPlayIng:NO];
        }
    }
}

-(void)playMusic:(FSMusic *)music playViewCell:(FSMusicCell *)cell{
    //
    if ([_music isEqual:music]) {
        // 相同的音乐
        [cell setIsPlayIng:!cell.isPlayIng];
        
        if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
            [[FSMusicPlayer sharedPlayer] pause];
        }else{
            [[FSMusicPlayer sharedPlayer] play];
        }
    }else{
        //
        if (_music) {
            NSInteger index = [self.musics indexOfObject:_music];
            NSIndexPath *IndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            FSMusicCell *preCell = [self.tableView cellForRowAtIndexPath:IndexPath];
            [preCell setIsPlayIng:NO];
        }
        
        [self.view addSubview:self.loading];
        [self.loading loadingViewShow];
        [cell setIsPlayIng:YES];
        
        if (music.songUrl) {
            
            NSString *url = music.songUrl;
            if (![url hasPrefix:@"http"]) {
                //@"http://35.158.218.231/"    http://10.10.32.152:20000/
                url = [AddressIP stringByAppendingString:music.songUrl];
            }
            __weak typeof(self) weakS = self;
            [FSMusicManager downLoadMusic:url complete:^(NSString *localPath, NSError *error) {
                [weakS.loading loadingViewhide];

                if (!error) {
                    [[FSMusicPlayer sharedPlayer] stop];
                    [[FSMusicPlayer sharedPlayer] setFilePath:localPath];
                }else{
                    return ;
                }
                
                if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
                    [[FSMusicPlayer sharedPlayer] pause];
                }else{
                    [[FSMusicPlayer sharedPlayer] play];
                }
            }];
        }else{
            // 测试数据
            if (![_music isEqual:music]) {
                NSString *filePath = [[NSBundle mainBundle] pathForResource:music.songTitle ofType:@"mp3"];
                [[FSMusicPlayer sharedPlayer] stop];
                [[FSMusicPlayer sharedPlayer] setFilePath:filePath];
                
            }
            
            if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
                [[FSMusicPlayer sharedPlayer] pause];
            }else{
                [[FSMusicPlayer sharedPlayer] play];
            }
            
            [self.loading loadingViewhide];
            
        }
    }
    // 更新当前选中的音乐
    _music = music;
}

-(void)tableView:(UITableView *)tableView updateTableWithMusic:(FSMusic *)music selectIndexPath:(NSIndexPath *)indexPath{

    if (![_music isEqual:music]) {
        NSIndexPath *selectedPath = nil;
        if (_music) {
            NSInteger index = [self.musics indexOfObject:_music];
            selectedPath = [NSIndexPath indexPathForRow:index inSection:0];
            _music.opend =  NO;
        }
        music.opend = YES;
        NSMutableArray *paths = [NSMutableArray array];
        if (selectedPath) {
            [paths addObject:selectedPath];
        }
        [paths addObject:indexPath];
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:paths withRowAnimation:(UITableViewRowAnimationFade)];
        [tableView endUpdates];
    }
}

-(void)musicCell:(FSMusicCell *)cell wouldPlay:(FSMusic *)music{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    [self tableView:self.tableView updateTableWithMusic:music selectIndexPath:indexPath];

    [self playMusic:music playViewCell:cell];
}
#pragma mark -
-(void)musicCell:(FSMusicCell *)cell wuoldUseMusic:(FSMusic *)music{
    
    NSString *path = nil;
    if (music.songUrl) {
        NSString *localPath = [FSMusicManager musicPathWithFileName:music.songUrl];
        path = localPath;
    }else{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:music.songTitle ofType:@"mp3"];
        path = bundlePath;
    }

    [[FSMusicPlayer sharedPlayer] stop];
    
    if (_pushed) {
        
        if ([self.delegate respondsToSelector:@selector(musicControllerSelectMusic:musicId:)]) {
            [self.delegate musicControllerSelectMusic:path musicId:music.songId];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        
        FSShortVideoRecorderController *recoder = [[FSShortVideoRecorderController alloc] init];
        recoder.musicFilePath = path;
        [self.navigationController pushViewController:recoder animated:YES];
    }
}



#pragma mark -
- (void)musicSeverGetMusics:(NSArray<FSMusic *> *)musics{
    [self.loading loadingViewhide];
    
    [self.musics addObjectsFromArray:musics];
    [self.tableView reloadData];
}
-(void)musicSeverGetFaild{
    [self.loading loadingViewhide];

}
-(void)dealloc{
    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
