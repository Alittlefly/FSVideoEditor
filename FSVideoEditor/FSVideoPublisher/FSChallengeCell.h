//
//  FSChallengeCell.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSChallengeModel.h"

@protocol FSChallengeCellDelegate <NSObject>

- (void)fsChallengeCellAddNewChallenge:(NSString *)title;

@end

@interface FSChallengeCell : UITableViewCell

@property (nonatomic, weak) id<FSChallengeCellDelegate> delegate;
@property (nonatomic, strong) FSChallengeModel *challengeModel;

@end
