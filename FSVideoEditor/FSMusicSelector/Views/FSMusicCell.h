//
//  FSMusicCell.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/30.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FSMusicCell;
@protocol FSMusicCellDelegate <NSObject>

-(void)musicCell:(FSMusicCell *)cell wouldPlay:(NSString *)music;

@end

@interface FSMusicCell : UITableViewCell

@property(nonatomic,assign)id<FSMusicCellDelegate>delegate;
@property(nonatomic,strong)NSString * music;
+(instancetype)musicCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@end
