//
//  FSAddChallengeAPI.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/26.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSAddChallengeAPIDelegate <NSObject>

- (void)FSAddChallengeAPIAddChallengeSucceed:(NSDictionary *)dataInfo;
- (void)FSAddChallengeAPIAddChallengeFailed:(NSError *)error;
- (void)FSAddChallengeAPIAddChallengeCode:(NSInteger)code;

@end

@interface FSAddChallengeAPI : NSObject

@property (nonatomic, weak) id<FSAddChallengeAPIDelegate> delegate;

- (void)addNewChallenge:(id)param;

@end
