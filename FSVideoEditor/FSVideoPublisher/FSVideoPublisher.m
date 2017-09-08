//
//  FSVideoPublisher.m
//  FSVideoEditor
//
//  Created by Charles on 2017/9/8.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoPublisher.h"
#import "FSDraftFileManager.h"

@implementation FSVideoPublisher
+(instancetype)sharedPublisher{
    return [[FSVideoPublisher alloc] init];
}

// 发布 视频文件
-(void)publishVideo:(FSVideoPublishParam *)param{

}

// 杀应用 要删除一下file
-(void)terminate{

}
@end
