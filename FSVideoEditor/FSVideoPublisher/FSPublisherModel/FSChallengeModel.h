//
//  FSChallengeModel.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FSChallengeModel : NSObject

@property (nonatomic, assign) NSInteger challengeId;  //挑战id
@property (nonatomic, assign) NSInteger challengeType;//挑战的类型
@property (nonatomic, copy) NSString *name;           //挑战名称
@property (nonatomic, copy) NSString *content;        //挑战描述
@property (nonatomic, assign) NSInteger personCount;  //挑战下总视频数
@property (nonatomic, assign) CGFloat cellHeight;

+ (NSArray *)getDataArrayFromArray:(NSArray *)array;

@end
