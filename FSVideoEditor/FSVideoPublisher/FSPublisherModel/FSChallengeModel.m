//
//  FSChallengeModel.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSChallengeModel.h"

@implementation FSChallengeModel

+ (NSArray *)getDataArrayFromArray:(NSArray *)array {
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dic in array) {
        FSChallengeModel *model = [[FSChallengeModel alloc] init];
        [model setChallengeId:[[dic objectForKey:@"di"] integerValue]];
        [model setPersonCount:[[dic objectForKey:@"c"] integerValue]];
        [model setChallengeType:[[dic objectForKey:@"dt"] integerValue]];
        [model setName:[dic objectForKey:@"dn"]];
        [model setContent:[dic objectForKey:@"dd"]];
        
        CGSize size = [model.content boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-40-12-5, 999) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
        model.cellHeight = ceilf(size.height)+50;
        
        [dataArray addObject:model];
    }
    return dataArray;
}

- (instancetype)init {
    if (self = [super init]) {
        _challengeId = 0;
        _personCount = 0;
        _cellHeight = 50;
    }
    return self;
}

@end
