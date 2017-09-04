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

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *loginKey;
@property (nonatomic, assign) BOOL isAutoReverse;
@property (nonatomic, copy) NSString *language;

@property (nonatomic, copy) NSString *addressAPILogin;
@property (nonatomic, copy) NSString *addressUpload;
@property (nonatomic, copy) NSString *addressAPI;

@property (nonatomic, assign) BOOL isAR; //项目分支，yes是7nujoom，no是haahi
@property (nonatomic, strong) NSMutableArray *likeMusicArray; //收藏音乐列表

+ (instancetype)sharedInstance;

- (void)cleanData;

@end
