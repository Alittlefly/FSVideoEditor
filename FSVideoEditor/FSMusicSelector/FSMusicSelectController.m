//
//  FSMusicSelectController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicSelectController.h"
#import "FSMusicController.h"
#import "FSSearchBar.h"
#import "FSMusicCell.h"

@interface FSMusicSelectController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
{

}
@property(nonatomic,strong)FSMusicController *musicController;
@property(nonatomic,strong)FSSearchBar *searchBar;
@property(nonatomic,strong)UITableView *contentTableView;
@end

@implementation FSMusicSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _searchBar = [[FSSearchBar alloc] initWithFrame:CGRectMake(10, 8, CGRectGetWidth(self.view.bounds) - 20, 28) delegate:self];
    [self.view addSubview:_searchBar];
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
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if([searchBar canResignFirstResponder]){
        [searchBar resignFirstResponder];
    }
    [_searchBar setShowCancle:NO];
    
    NSString *trimText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"要查询的内容是 trimText %@",trimText);
}
@end
