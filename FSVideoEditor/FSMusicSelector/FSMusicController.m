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
#import "FSMusicCollectSever.h"
#import "FSMusicManager.h"
#import "FSEditorLoading.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"
#import "FSSearchBar.h"
#import "FSMusicHeaderView.h"
#import "FSMusicSearchResultView.h"
#import "FSMusicListController.h"
#import "FSMusicListView.h"

@interface FSMusicController ()<FSMusicListViewDelegate,FSMusicSeverDelegate,UISearchBarDelegate,FSMusicHeaderViewDelegate,FSMusicCollectSeverDelegate>{
    FSMusic *_music;
    FSMusicSever *_sever;
    FSMusicCollectSever *_collectSever;
}
@property(nonatomic,strong)FSMusicListView *musicListView;
@property(nonatomic,strong)NSMutableArray *musics;
@property(nonatomic,strong)FSSearchBar *searchBar;
@property(nonatomic,strong)FSMusicSearchResultView *resultView;
@property(nonatomic,strong)FSMusicHeaderView *tableHeader;

@end

@implementation FSMusicController

-(NSMutableArray *)musics{
    if (!_musics) {
        _musics = [NSMutableArray array];
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
    
     _tableHeader = [[FSMusicHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 228)];
    [_tableHeader setDelegate:self];
    
    _musicListView = [[FSMusicListView alloc] initWithFrame:self.view.bounds];
    _musicListView.tableHeader = _tableHeader;
    [_musicListView setDelegate:self];
    [self.view addSubview:_musicListView];

    
     _resultView = [[FSMusicSearchResultView alloc] initWithFrame:self.view.bounds];
    [_resultView setDelegate:self];
    [_resultView setHidden:YES];
    [self.view addSubview:_resultView];
    
     _sever = [[FSMusicSever alloc] init];
    [_sever setDelegate:self];
    [_sever getMusicList];
    
    _collectSever = [FSMusicCollectSever new];
    [_collectSever setDelegate:self];
    
    [_musicListView showLoading:YES];
    
    [self initCancleButton];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_musicListView stopPlayCurrentMusic];
}
#pragma mark -
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"searchBarShouldBeginEditing ");
    [_searchBar setShowCancle:YES];
    [_resultView setHidden:NO];
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [_searchBar setShowCancle:NO];
    return YES;
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [_resultView setMusics:[NSArray array]];
    [_resultView setHidden:YES];
    NSLog(@"点击取消");
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if([searchBar canResignFirstResponder]){
        [searchBar resignFirstResponder];
    }
    [_searchBar setShowCancle:NO];
    
    NSString *trimText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"要查询的内容是 trimText %@",trimText);
    
    //
    [_sever getMusicListWithSearchKey:trimText no:1];
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    [_searchBar setFrame:CGRectMake(10, 8, CGRectGetWidth(self.view.bounds) - 20, 28)];
    
    CGRect tableFrame = CGRectMake(0, CGRectGetMaxY(_searchBar.frame) + 15, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 100);
    [_musicListView setFrame:tableFrame];
    [_resultView setFrame:tableFrame];
    
    [self.cancleButton setFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49)];
}
- (void)stopPlayCurrentMusic {
    [_musicListView stopPlayCurrentMusic];
}

#pragma mark -
-(void)musicListWouldUseMusic:(FSMusic *)music musicPath:(NSString *)musicPath{
    if (_pushed) {
        if ([self.delegate respondsToSelector:@selector(musicControllerSelectMusic:musicId:)]) {
            [self.delegate musicControllerSelectMusic:musicPath musicId:music.songId];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        FSShortVideoRecorderController *recoder = [[FSShortVideoRecorderController alloc] init];
        recoder.musicFilePath = musicPath;
        [self.navigationController pushViewController:recoder animated:YES];
    }
}
-(void)musicListWouldShowDetail:(FSMusic *)music{
    if ([self.delegate respondsToSelector:@selector(musicControllerWouldShowMusicDetail:)]) {
        UIViewController *viewController = [self.delegate musicControllerWouldShowMusicDetail:music];
        if (viewController) {
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

#pragma mark -
- (void)musicSeverGetMusics:(NSArray<FSMusic *> *)musics musicTypes:(NSArray<FSMusicType *> *)musicTypes{
    
    [_tableHeader setItems:musicTypes];
    
    [self.musicListView showLoading:NO];
    [self.musics addObjectsFromArray:musics];

    [self.musicListView setMusics:[self.musics copy]];
}
-(void)musicSeverGetFaild{
    [self.musicListView setMusics:[self.musics copy]];
    [self.musicListView showLoading:NO];
}

#pragma mark - 
-(void)musicHeaderViewSelectItem:(FSMusicType *)item{
    FSMusicListController *musicListController = [[FSMusicListController alloc] init];
    musicListController.musicType = item;
    musicListController.delegate = self;
    [self.navigationController pushViewController:musicListController animated:YES];
}
-(void)musicHeaderShouldBeFrame:(CGRect)frame{
    _musicListView.tableHeader = [UIView new];
    [_tableHeader setFrame:frame];
    _musicListView.tableHeader = _tableHeader;
}
-(void)musicHeaderClickTypeButton:(FSMusicButtonType)type{
    if (type == FSMusicButtonTypeHot) {
        [_sever getMusicList];
    }else{
        [_collectSever getLikedMusicsList:1];
        [self.musicListView showLoading:YES];
    }
}
#pragma mark -
-(void)musicSeverGetCollectedMusics:(NSArray<FSMusic *> *)musics{
    [self.musicListView setMusics:musics];
    [self.musicListView showLoading:NO];
}
-(void)musicSeverSearched:(NSArray<FSMusic *>*)musics{
    [_resultView setMusics:musics];
}
-(void)dealloc{
    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

@end
