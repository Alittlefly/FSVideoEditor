//
//  FSChallengeController.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSChallengeModel.h"


@protocol FSChallengeControllerDelegate <NSObject>

- (void)FSChallengeControllerChooseChallenge:(FSChallengeModel *)model;

@end

@interface FSChallengeController : UIViewController

@property (nonatomic, weak) id<FSChallengeControllerDelegate> delegate;

@end
