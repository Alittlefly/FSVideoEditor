//
//  FSDraftManager.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDraftInfo.h"
@interface FSDraftManager : NSObject
+(instancetype)sharedDraftManager;
// 原始数据 与临时数据
-(FSDraftInfo *)tempTimeLineInfoWithPreInfo:(FSDraftInfo *)timeLineInfo;
-(void)clearInfo;
-(void)mergeInfo;
-(void)saveToLocal;
-(void)cancleOperate;
-(void)delete:(FSDraftInfo *)draftInfo;
-(FSDraftInfo *)draftInfoWithPreInfo:(FSDraftInfo *)preDraftInfo;
@end
