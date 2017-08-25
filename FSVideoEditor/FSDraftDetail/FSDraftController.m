//
//  FSDraftController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/4.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftController.h"
#import "FSDraftManager.h"
#import "FSDraftTableViewCell.h"
#import "FSPublisherController.h"
#import "FSShortVideoRecorderController.h"
#import "FSToolController.h"
#import "FSAnimationNavController.h"
#import "FSPublishSingleton.h"
#import "FSVideoEditorCommenData.h"
#import "FSDraftEmptyView.h"

@interface FSDraftController ()<FSDraftTableCellDelegate>
@property(nonatomic,strong)NSMutableArray *drafts;

@property(nonatomic,strong)NSMutableArray *draftsMisic;

@property(nonatomic,strong)NSMutableDictionary *draftsMisicDict;

@property(nonatomic,strong)FSDraftEmptyView *emptyView;

@end

@implementation FSDraftController


-(FSDraftEmptyView *)emptyView{
    if (!_emptyView) {
        _emptyView = [[FSDraftEmptyView alloc] initWithFrame:self.view.bounds];
//        [_emptyView setBackgroundColor:FSHexRGB(0xEFEFF4)];
//        [_emptyView.imageIcon setImage:[UIImage imageNamed:@"draft_empty_image"]];
//        [_emptyView.message setText:[FSShortLanguage CustomLocalizedStringFromTable:@"emptyDraft"]];
        [self.view addSubview:_emptyView];
    }
    return _emptyView;
}

-(NSMutableArray *)draftsMisic{
    if (!_draftsMisic) {
        _draftsMisic = [NSMutableArray array];
    }
    return _draftsMisic;
}

-(NSMutableDictionary *)draftsMisicDict{
    if (!_draftsMisicDict) {
        _draftsMisicDict = [NSMutableDictionary dictionary];
    }
    return _draftsMisicDict;
}

-(void)TheTitleLabel{
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor = FSHexRGB(0x292929);
    [titleLabel setText:[FSShortLanguage CustomLocalizedStringFromTable:@"DraftTitle"]];
    self.navigationItem.titleView = titleLabel;
}

-(void)creatDeleteBtn{
    
    NSString * saveTitle = [FSShortLanguage CustomLocalizedStringFromTable:@"deletaAll"];
    UIButton *deleteButton = [[UIButton alloc] init];
    [deleteButton setTitle:saveTitle forState:UIControlStateNormal];
    [deleteButton setTitleColor:FSHexRGB(0xD50000) forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [deleteButton addTarget:self action:@selector(clickDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:21]};
    CGRect newSize = [saveTitle boundingRectWithSize:CGSizeMake(0, 10000) options:(NSStringDrawingUsesFontLeading) attributes:dict context:nil];
    
    [deleteButton setFrame:CGRectMake(0, 0, newSize.size.width, 21)];
    
    UIBarButtonItem *roghtBar = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
    [self.navigationItem setRightBarButtonItem:roghtBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:FSHexRGB(0xEFEFF4)];
    
    [self TheTitleLabel];
    [self creatDeleteBtn];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _drafts =  [NSMutableArray arrayWithArray:[[FSDraftManager sharedManager] allDraftInfos]];
    
    [self dealWithDraftData:_drafts];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 47)];
    
    UILabel *label = [[UILabel alloc] init];
    [label setFrame:CGRectMake(40, 0, CGRectGetWidth(self.view.bounds) - 80, 47)];
    [label setFont:[UIFont systemFontOfSize:13]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:FSHexRGB(0x999999)];
    [label setText:[FSShortLanguage CustomLocalizedStringFromTable:@"OnlyYouCanSee"]];
    [view addSubview:label];
    
    [self.tableView setTableFooterView:view];
    [self.tableView registerClass:[FSDraftTableViewCell class] forCellReuseIdentifier:@"FSDraftTableViewCell"];
}

-(void)dealWithDraftData:(NSMutableArray*)drafts{
    for (FSDraftInfo* info in drafts) {
        NSMutableArray* tempArray = [self.draftsMisicDict objectForKey:[NSNumber numberWithInteger:info.vMusic.mId]];
        if (tempArray) {
            [tempArray addObject:info];
        }else{
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:info];
            [self.draftsMisic addObject:array];
            [self.draftsMisicDict setObject:array forKey:[NSNumber numberWithInteger:info.vMusic.mId]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self.draftsMisic count] == 0) {
        [self.emptyView setHidden:NO];
        [self.tableView.tableFooterView setHidden:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }else{
        [self.emptyView setHidden:YES];
        [self.tableView.tableFooterView setHidden:NO];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    return [self.draftsMisic count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat cellW = CGRectGetWidth(self.view.bounds);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellW, 44)];//
    [view setBackgroundColor:[UIColor whiteColor]];
    
    
    UIImageView *musicPic = [[UIImageView alloc] init];
    [musicPic setFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse?:15.8, 12.8, 18.4, 18.4)];
    [musicPic setImage:[UIImage imageNamed:@"pic_music"]];
    [view addSubview:musicPic];
    
    NSMutableArray* tempArray = [self.draftsMisic objectAtIndex:section];
    FSDraftInfo *info = [tempArray objectAtIndex:0];

    UILabel *musicName = [[UILabel alloc] init];
    [musicName setFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse?cellW - 41 - 130:41, 14, 130, 16)];
    [musicName setFont:[UIFont systemFontOfSize:14]];
    [musicName setTextAlignment:[FSPublishSingleton sharedInstance].isAutoReverse?NSTextAlignmentRight:NSTextAlignmentLeft];
    [musicName setTextColor:FSHexRGB(0x292929)];
    [musicName setText:info.vMusic.mName];
    [view addSubview:musicName];
    
    
    UILabel *tip = [[UILabel alloc] init];
    [tip setFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse?25:cellW - 25 - 130, 14, 130, 16)];
    [tip setFont:[UIFont systemFontOfSize:14]];
    [tip setTextAlignment:[FSPublishSingleton sharedInstance].isAutoReverse?NSTextAlignmentLeft:NSTextAlignmentRight];
    [tip setTextColor:FSHexRGB(0x0BC2C6)];
    [tip setText:[FSShortLanguage CustomLocalizedStringFromTable:@"TakePhotoAgain"]];
    [view addSubview:tip];
    
    
    UIImageView *arrowPic = [[UIImageView alloc] init];
    [arrowPic setFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse?0:cellW - 20, 12, 20, 20)];
    [arrowPic setImage:[UIImage imageNamed:@"paly_icon_image"]];
    [view addSubview:arrowPic];
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse?0:30, 43, cellW - 30, 1)];
    [line setBackgroundColor:FSHexRGB(0xeeeeee)];
    [view addSubview:line];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse?0:cellW - 150, 0, 150, 44)];
    button.tag = section;
    [button addTarget:self action:@selector(photoAgain:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray* tempArray = [self.draftsMisic objectAtIndex:section];
    return [tempArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 4.0;
}
/**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSDraftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FSDraftTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSMutableArray* tempArray = [self.draftsMisic objectAtIndex:indexPath.section];
    FSDraftInfo *info = [tempArray objectAtIndex:indexPath.row];
    NSLog(@"info %@",info.vFinalPath);
    [cell setInfo:info];
    [cell setDelegate:self];
    cell.indexPath = indexPath;
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 101;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FSDraftInfo *info = [_drafts objectAtIndex:indexPath.row]
    ;

    if (info.vType == FSDraftInfoTypeRecoder) {
        
        FSShortVideoRecorderController *controller = [[FSShortVideoRecorderController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        controller.draftInfo = info;
        
        FSPublisherController *publishController = [[FSPublisherController alloc] init];
        publishController.draftInfo = info;
        [nav pushViewController:publishController animated:NO];
        
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        FSPublisherController *publishController = [[FSPublisherController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:publishController];
        publishController.draftInfo = info;
        [self presentViewController:nav animated:YES completion:nil];
    }
    
}

#pragma mark - UITableViewDataSource

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return   UITableViewCellEditingStyleDelete;
}
//先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//进入编辑模式，按下出现的编辑按钮后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak FSDraftController *weakSelf = self;
    [tableView setEditing:NO animated:YES];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[FSShortLanguage CustomLocalizedStringFromTable:@"deleteAlert"] preferredStyle:UIAlertControllerStyleAlert];
        //        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"MessageOK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [tableView beginUpdates];

            NSMutableArray* tempArray = [weakSelf.draftsMisic objectAtIndex:indexPath.section];
            FSDraftInfo *info = [tempArray objectAtIndex:indexPath.row];
            [[FSDraftManager sharedManager] delete:info];
            
            [tempArray removeObject:info];
            if ([tempArray count]) {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }else{
                [weakSelf.draftsMisic removeObjectAtIndex:indexPath.section];
                [weakSelf.draftsMisicDict removeObjectForKey:[NSNumber numberWithInteger:info.vMusic.mId]];
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [tableView endUpdates];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"MessageCancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"        ";
}
//设置进入编辑状态时，Cell不会缩进
- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)photoAgain:(UIButton*)sender{
    NSMutableArray* tempArray = [self.draftsMisic objectAtIndex:sender.tag];
    FSDraftInfo *info = [tempArray objectAtIndex:0];
    
    FSShortVideoRecorderController *controller = [[FSShortVideoRecorderController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    controller.draftInfo = info;
    
    FSPublisherController *publishController = [[FSPublisherController alloc] init];
    publishController.draftInfo = info;
    [nav pushViewController:publishController animated:NO];
    
    [self presentViewController:nav animated:YES completion:nil];
}
-(void)clickDeleteButton{
    __weak FSDraftController *weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[FSShortLanguage CustomLocalizedStringFromTable:@"deleteAllAlert"] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"MessageOK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[FSDraftManager sharedManager] deleteAllDrafts];
        [weakSelf.draftsMisic removeAllObjects];
        [weakSelf.draftsMisicDict removeAllObjects];
        [weakSelf.tableView reloadData];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"MessageCancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - FSDraftTableCellDelegate
-(void)FSDraftTableCellDelegatePlayIconOnclik:(FSDraftTableViewCell*)cell{
}
-(void)FSDraftTableCellDelegateMoreButtonOnclik:(FSDraftTableViewCell*)cell{

}


@end
