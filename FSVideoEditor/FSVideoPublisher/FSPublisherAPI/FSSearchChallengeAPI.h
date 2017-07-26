//
//  FSSearchChallengeAPI.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSSearchChallengeAPIDelegate <NSObject>

- (void)FSSearchChallengeAPISucceed:(NSDictionary *)dic;
- (void)FSSearchChallengeAPIFailed:(NSError *)error;

@end

@interface FSSearchChallengeAPI : NSObject

@property (nonatomic, weak) id<FSSearchChallengeAPIDelegate> delegate;

- (void)searchChallenge:(id)param;

@end
