//
//  FSMusicCell.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/30.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSMusic.h"
@class FSMusicCell;

@protocol FSMusicCellDelegate <NSObject>

-(void)musicCell:(FSMusicCell *)cell wouldPlay:(FSMusic *)music;

-(void)musicCell:(FSMusicCell *)cell wuoldUseMusic:(FSMusic *)music;

@end

@interface FSMusicCell : UITableViewCell

@property(nonatomic,assign)id<FSMusicCellDelegate>delegate;
@property(nonatomic,strong)FSMusic * music;
@property(nonatomic,assign)BOOL isPlayIng;
+(instancetype)musicCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@end
