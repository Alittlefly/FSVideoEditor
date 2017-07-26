//
//  FSAddChallengeController.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSChallengeModel.h"

@protocol FSAddChallengeControllerDelegate <NSObject>

- (void)FSAddChallengeControllerNewChallenge:(FSChallengeModel *)model;

@end

@interface FSAddChallengeController : UIViewController

@property (nonatomic, weak) id<FSAddChallengeControllerDelegate> delegate;
@property (nonatomic, copy) NSString *challengeName;

@end
