//
//  FSChallengeDataServer.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSChallengeModel.h"

@protocol FSChallengeDataServerDelegate <NSObject>

- (void)FSChallengeDataServerSucceed:(NSArray *)array;
- (void)FSChallengeDataServerFailed:(NSError *)error;

- (void)FSChallengeDataServerAddChallengeSucceed:(FSChallengeModel *)model;
- (void)FSChallengeDataServerAddChallengeFailed:(NSError *)error;

@end

@interface FSChallengeDataServer : NSObject

@property (nonatomic, weak) id<FSChallengeDataServerDelegate> delegate;

- (void)requestChallengeDataList:(id)param isSearch:(BOOL)isSearch;
- (void)addNewChallenge:(FSChallengeModel *)model;

@end
