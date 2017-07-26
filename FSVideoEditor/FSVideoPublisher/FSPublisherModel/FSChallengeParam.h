//
//  FSChallengeParam.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSChallengeParam : NSObject

@property (nonatomic, copy) NSString *w;    //搜索关键字
@property (nonatomic, assign) NSInteger no;  //分页起始位置
@property (nonatomic, assign) NSInteger size;  //分页大小


@end
