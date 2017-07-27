//
//  FSPublishSingleton.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSMusic.h"
#import "FSChallengeModel.h"

@interface FSPublishSingleton : NSObject

@property (nonatomic, strong) FSMusic *chooseMusic;
@property (nonatomic, strong) FSChallengeModel *chooseChallenge;

+ (instancetype)sharedInstance;

- (void)cleanData;

@end
