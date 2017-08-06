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

@interface FSDraftController ()<FSDraftTableCellDelegate>
@property(nonatomic,strong)NSArray *drafts;
@end

@implementation FSDraftController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _drafts = [[FSDraftManager sharedManager] allDraftInfos];
    
    [self.tableView setTableFooterView:[UIView new]];
    [self.tableView registerClass:[FSDraftTableViewCell class] forCellReuseIdentifier:@"FSDraftTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_drafts count];
}

/**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSDraftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FSDraftTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    FSDraftInfo *info = [_drafts objectAtIndex:indexPath.row];
    NSLog(@"info %@",info.vFinalPath);
    [cell setInfo:info];
    [cell setDelegate:self];
    
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
        FSAnimationNavController *nav = [[FSAnimationNavController alloc] initWithRootViewController:controller];
        controller.draftInfo = info;
        
        FSPublisherController *publishController = [[FSPublisherController alloc] init];
        publishController.draftInfo = info;
        [nav pushViewController:publishController animated:NO];
        
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        FSPublisherController *publishController = [[FSPublisherController alloc] init];
        FSAnimationNavController *nav = [[FSAnimationNavController alloc] initWithRootViewController:publishController];
        publishController.draftInfo = info;
        [self presentViewController:nav animated:YES completion:nil];
    }
    
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

#pragma mark - FSDraftTableCellDelegate
-(void)FSDraftTableCellDelegatePlayIconOnclik:(FSDraftTableViewCell*)cell{
}
-(void)FSDraftTableCellDelegateMoreButtonOnclik:(FSDraftTableViewCell*)cell{
}


@end
