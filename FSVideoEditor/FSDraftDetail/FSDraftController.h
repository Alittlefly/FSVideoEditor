//
//  FSDraftController.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/4.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSDraftTableViewCell.h"

@interface FSDraftController : UITableViewController

-(void)deleteAllDrafts;//删除所有草稿
-(void)deleteDraftCell:(FSDraftTableViewCell*)cell;//删除草稿
@end
