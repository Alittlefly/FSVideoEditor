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
#import "FSPublishSingleton.h"

@interface FSMusicController ()<FSMusicListViewDelegate,FSMusicSeverDelegate,UISearchBarDelegate,FSMusicHeaderViewDelegate,FSMusicCollectSeverDelegate>{
    FSMusic *_music;
    FSMusicSever *_sever;
    FSMusicCollectSever *_collectSever;
    
    FSMusicButtonType _currentType;
    
    NSInteger _currentHotPage;
    NSInteger _currentCollectPage;
    NSInteger _searchPage;
}
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)UIView *contentViewWhenNeedSelfHeader;
@property(nonatomic,strong)FSMusicListView *musicListView;
@property(nonatomic,strong)NSMutableArray *musics;
@property(nonatomic,strong)NSMutableArray *collectedMusics;
@property(nonatomic,strong)FSSearchBar *searchBar;
@property(nonatomic,strong)FSMusicSearchResultView *resultView;
@property(nonatomic,strong)FSMusicHeaderView *tableHeader;

@end

@implementation FSMusicController
- (void)searchMusic{}
- (void)clickHotMusic{}
- (void)clickCollectMusic{}
- (void)clickHotDetail{}
- (void)clickHotUseMusic{}
- (void)clickHotCollect{}
- (void)clickHotPlay{}

- (void)clickFaveDeatil{}
- (void)clickFaveUseMusic{}
- (void)clickFaveCollect{}
- (void)clickFavePlay{}

-(NSMutableArray *)collectedMusics{
    if (!_collectedMusics) {
        _collectedMusics = [NSMutableArray array];
    }
    return _collectedMusics;
}
-(NSMutableArray *)musics{
    if (!_musics) {
        _musics = [NSMutableArray array];
    }
    return _musics;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_needSelfHeader) {
        _contentViewWhenNeedSelfHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 20,CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        [_contentViewWhenNeedSelfHeader setBackgroundColor:[UIColor whiteColor]];
        [_contentViewWhenNeedSelfHeader.layer setCornerRadius:5.0];
        [_contentViewWhenNeedSelfHeader.layer setMasksToBounds:YES];
        [self.view addSubview:_contentViewWhenNeedSelfHeader];
        
        
        UIButton *selectMusic = [UIButton buttonWithType:UIButtonTypeCustom];
        selectMusic.frame = CGRectMake((CGRectGetWidth(self.view.frame) - 60)/2.0, 17, 60, 21);
        [selectMusic setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"ChooseMusic"] forState:UIControlStateNormal];
        selectMusic.tag = 2;
        [selectMusic setTitleColor:FSHexRGB(0x73747B) forState:(UIControlStateNormal)];
        [selectMusic setTitleColor:FSHexRGB(0x010A12) forState:(UIControlStateSelected)];
        [selectMusic.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [selectMusic setSelected:YES];
        [_contentViewWhenNeedSelfHeader addSubview:selectMusic];
    }
    
    
     _contentView = [UIView new];
    [_contentView setFrame:self.view.bounds];
    [self.view addSubview:_contentView];

    
     _searchBar = [[FSSearchBar alloc] initWithFrame:CGRectMake(10, 8, CGRectGetWidth(self.view.bounds) - 20, 28) delegate:self];
    [_contentView addSubview:_searchBar];
    
    _tableHeader = [[FSMusicHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 228)];
    [_tableHeader setDelegate:self];
    
    _musicListView = [[FSMusicListView alloc] initWithFrame:self.view.bounds];
    _musicListView.tableHeader = _tableHeader;
    [_musicListView setDelegate:self];
    _musicListView.tag = 10;
    [_contentView addSubview:_musicListView];
    
    
    _resultView = [[FSMusicSearchResultView alloc] initWithFrame:self.view.bounds];
    [_resultView setDelegate:self];
    [_resultView setHidden:YES];
    [_contentView addSubview:_resultView];
    
//    [self initCancleButton];
    if (!self.cancleButton) {
        self.cancleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49)];
    }
    
    [self.cancleButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Cancle"] forState:(UIControlStateNormal)];
    [self.cancleButton setBackgroundColor:FSHexRGB(0xffffff)];
    [self.cancleButton setTitleColor:FSHexRGB(0x73747B) forState:(UIControlStateNormal)];
    [self.cancleButton.layer setShadowOffset:CGSizeMake(0.0, -2.0)];
    [self.cancleButton.layer setShadowRadius:3.0];
    [self.cancleButton.layer setShadowColor:FSHexRGBAlpha(0x000000,1.0).CGColor];
    [self.cancleButton.layer setShadowOpacity:0.1];
    [self.cancleButton addTarget:self action:@selector(dissmissController) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:self.cancleButton];
    
    _currentType = FSMusicButtonTypeHot;
     _sever = [[FSMusicSever alloc] init];
    [_sever setDelegate:self];
    _currentHotPage = 1;
    _currentCollectPage = 1;
    [_sever getMusicListPage:_currentHotPage];
     _collectSever = [FSMusicCollectSever new];
    [_collectSever setDelegate:self];
    [_musicListView showLoading:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_musicListView reload];
    if (_currentType == FSMusicButtonTypeLike) {
        _currentCollectPage = 1;
        [_collectSever getLikedMusicsList:_currentCollectPage];
        [self.musicListView showLoading:YES];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_musicListView stopPlayCurrentMusic];
    
    [_collectedMusics removeAllObjects];

//    if ([self.delegate respondsToSelector:@selector(musicControllerHideen)]) {
//        [self.delegate musicControllerHideen];
//    }
}
#pragma mark -
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"searchBarShouldBeginEditing ");
    [_searchBar setShowCancle:YES];
    [_resultView setMusics:[NSArray array]];
    [_resultView setHidden:NO];
    
    [_musicListView stopPlayCurrentMusic];
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
    _searchPage = 0;
    _resultView.searchKey = @"";
    [_musicListView stopPlayCurrentMusic];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if([searchBar canResignFirstResponder]){
        [searchBar resignFirstResponder];
    }
    [_searchBar setShowCancle:NO];
    [_musicListView stopPlayCurrentMusic];

    NSString *trimText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"要查询的内容是 trimText %@",trimText);
    //
     _resultView.searchKey = trimText;
    [_resultView setMusics:nil];
    _searchPage = 1;
    [_sever getMusicListWithSearchKey:trimText no:_searchPage];
    [self searchMusic];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    
    if (_needSelfHeader) {
        [_contentView setFrame:CGRectMake(0, 55, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.frame)  - 55 - 20)];
    }else{
        [_contentView setFrame:self.view.bounds];
    }
    
    [_searchBar setFrame:CGRectMake(10, 8, CGRectGetWidth(_contentView.bounds) - 20, 28)];
    CGRect tableFrame = CGRectMake(0, CGRectGetMaxY(_searchBar.frame) + 15, CGRectGetWidth(_contentView.bounds), CGRectGetHeight(_contentView.bounds) - 100);
    [_musicListView setFrame:tableFrame];
    [_resultView setFrame:tableFrame];
    
    [self.cancleButton setFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49)];

}
- (void)stopPlayCurrentMusic {
    [_musicListView stopPlayCurrentMusic];
    [_resultView stopPlayCurrentMusic];
}

#pragma mark -
- (void)musicListViewWouldPlay:(FSMusic *)music{
    if (_currentType == FSMusicButtonTypeHot) {
        [self clickHotPlay];
    }else{
        [self clickFavePlay];
    }
}
-(void)musicListWouldUseMusic:(FSMusic *)music musicPath:(NSString *)musicPath{
    
    [FSPublishSingleton sharedInstance].chooseMusic = music;
    
    if (self.shouldReturnMusic) {
        if ([self.delegate respondsToSelector:@selector(musicControllerSelectMusic:music:)]) {
            [self.delegate musicControllerSelectMusic:musicPath music:music];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        FSShortVideoRecorderController *recoder = [[FSShortVideoRecorderController alloc] init];
        [self.navigationController pushViewController:recoder animated:YES];
    }
    
    if (_currentType == FSMusicButtonTypeHot) {
        [self clickHotUseMusic];
    }else{
        [self clickFaveUseMusic];
    }
    // 
}
-(void)musicListWouldShowDetail:(FSMusic *)music{
    
    if (_currentType == FSMusicButtonTypeHot) {
        [self clickHotDetail];
    }else{
        [self clickFaveDeatil];
    }
    
    if (self.shouldReturnMusic) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(musicControllerWouldShowMusicDetail:)]) {
        UIViewController *viewController = [self.delegate musicControllerWouldShowMusicDetail:music];
        if (viewController) {
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}
-(void)musicListWouldGetMoreData:(FSMusicListView *)listView{
    [_searchBar endEditing:YES];
    if (listView.tag == 10) {
        if (_currentType == FSMusicButtonTypeHot) {
            _currentHotPage ++;
            [_sever getMusicListPage:_currentHotPage];
        }else{
             _currentCollectPage ++;
            [_collectSever getLikedMusicsList:_currentCollectPage];
        }
    }else if(listView.tag == 100){
        _searchPage ++;
        [_sever getMusicListWithSearchKey:_resultView.searchKey no:_searchPage];
    }

}

- (void)musicListUpdateCollectState:(FSMusic *)music {
    
    if (_currentType == FSMusicButtonTypeHot) {
        [self clickHotCollect];
    }else{
        [self clickFaveCollect];
    }
    
//    for (FSMusic *oldMusic in self.musics) {
//        if (oldMusic.songId == music.songId) {
//            oldMusic.collected = music.collected;
//        }
//    }
//    
//    if (music.collected) {
//        if (_currentType == FSMusicButtonTypeHot) {
//            BOOL isCollected = NO;
//            for (FSMusic *oldMusic in self.collectedMusics) {
//                if (oldMusic.songId == music.songId) {
//                    isCollected = YES;
//                    break;
//                }
//            }
//            if (!isCollected) {
//                [self.collectedMusics addObject:music];
//            }
//        }
//        else if (_currentType == FSMusicButtonTypeLike) {
//            for (FSMusic *oldMusic in self.collectedMusics) {
//                if (oldMusic.songId == music.songId) {
//                    oldMusic.collected = music.collected;
//                }
//            }
//        }
//        
//    }
//    else {
//        for (FSMusic *oldMusic in self.collectedMusics) {
//            if (oldMusic.songId == music.songId) {
//                [self.collectedMusics removeObject:oldMusic];
//                break;
//            }
//        }
//    }
}

#pragma mark -
- (void)musicSeverGetMusics:(NSArray<FSMusic *> *)musics musicTypes:(NSArray<FSMusicType *> *)musicTypes{
    
    if([musics count] == 0){
        _currentHotPage --;
    }
    
    [_tableHeader setItems:musicTypes];
    [self.musicListView showLoading:NO];
    
    for (FSMusic *music in musics) {
        BOOL isNew = YES;
        for (FSMusic *oldMusic in self.musics) {
            if (music.songId == oldMusic.songId) {
                isNew = NO;
                break;
            }
        }
        
        if (isNew) {
            [self.musics addObject:music];
        }
    }
    
//    [self.musics addObjectsFromArray:musics];
    [self.musicListView setMusics:[self.musics copy]];
}
-(void)musicSeverGetFaild{
    _currentHotPage --;
    [self.musicListView setMusics:[self.musics copy]];
    [self.musicListView showLoading:NO];
}

#pragma mark - 
-(void)musicHeaderViewSelectItem:(FSMusicType *)item{
    FSMusicListController *musicListController = [[FSMusicListController alloc] init];
    musicListController.musicType = item;
    musicListController.delegate = self;
    musicListController.shouldReturnMusic = self.shouldReturnMusic;
    musicListController.delegate = self;
    [self.navigationController pushViewController:musicListController animated:YES];
}
-(void)musicHeaderShouldBeFrame:(CGRect)frame{
    _musicListView.tableHeader = [UIView new];
    [_tableHeader setFrame:frame];
    _musicListView.tableHeader = _tableHeader;
}
-(void)musicHeaderClickTypeButton:(FSMusicButtonType)type{

    if (_currentType == type) {
        return;
    }

    if ([[FSMusicPlayer sharedPlayer] isPlaying]) {
        [[FSMusicPlayer sharedPlayer] stop];
        
        [_musicListView stopPlayCurrentMusic];
        [_resultView stopPlayCurrentMusic];
    }
    
    _currentType = type;

    if (type == FSMusicButtonTypeHot) {
        
        [self clickHotMusic];
        
        if ([self.musics count] == 0) {
            [_sever getMusicListPage:1];
            [self.musicListView showLoading:YES];
        }else{
            [_musicListView setMusics:[self.musics copy]];
        }
        [self.collectedMusics removeAllObjects];
    }else{
        [_collectSever getLikedMusicsList:1];
        [self.musicListView showLoading:YES];
    }

}
#pragma mark -
-(void)musicSeverGetCollectedMusics:(NSArray<FSMusic *> *)musics{
    if([musics count] == 0){
        _currentCollectPage --;
    }
    for (FSMusic *music in musics) {
        BOOL isNew = YES;
        for (FSMusic *oldMusic in self.collectedMusics) {
            if (music.songId == oldMusic.songId) {
                isNew = NO;
                break;
            }
        }
        
        if (isNew) {
            [self.collectedMusics addObject:music];
        }
    }
//    [self.collectedMusics addObjectsFromArray:musics];
    [self.musicListView setMusics:[self.collectedMusics copy]];
    [self.musicListView showLoading:NO];
}
-(void)musicSeverGetCollectedFaild{
    _currentCollectPage --;
    [self.collectedMusics addObjectsFromArray:[NSArray array]];
    [self.musicListView setMusics:[self.collectedMusics copy]];
    [self.musicListView showLoading:NO];
}
#pragma mark -
-(void)musicSeverSearched:(NSArray<FSMusic *>*)musics{
    if ([musics count] == 0) {
        _searchPage --;
    }
    [_resultView insertMoreMusic:musics];
}
-(void)musicSeverSearchFaild{
     _searchPage --;
    [_resultView insertMoreMusic:nil];
}
-(void)dissmissController{
    [[FSMusicPlayer sharedPlayer] stop];
    [super dissmissController];
}
-(void)dealloc{
    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

@end
