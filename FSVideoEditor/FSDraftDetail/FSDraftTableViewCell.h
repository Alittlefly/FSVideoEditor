//
//  FSDraftTableViewCell.h
//  FSVideoEditor
//
//  Created by stu on 2017/8/6.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSDraftInfo.h"

@class FSDraftTableViewCell;

@protocol FSDraftTableCellDelegate <NSObject>

-(void)FSDraftTableCellDelegatePlayIconOnclik:(FSDraftTableViewCell*)cell;
-(void)FSDraftTableCellDelegateMoreButtonOnclik:(FSDraftTableViewCell*)cell;

@end

@interface FSDraftTableViewCell : UITableViewCell
@property(nonatomic ,strong) FSDraftInfo *info;
@property(nonatomic ,weak) id<FSDraftTableCellDelegate> delegate;
@property(nonatomic ,strong) NSIndexPath *indexPath;
@end
