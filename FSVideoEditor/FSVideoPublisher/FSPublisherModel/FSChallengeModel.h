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

@property (nonatomic, assign) NSInteger challengeId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSInteger personCount;
@property (nonatomic, assign) CGFloat cellHeight;

+ (NSArray *)getDataArrayFromArray:(NSArray *)array;

@end
