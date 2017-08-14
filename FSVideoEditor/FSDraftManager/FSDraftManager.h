//
//  FSDraftManager.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDraftInfo.h"
#import "FSDraftFileManager.h"
#import "FSMusicManager.h"

@interface FSDraftManager : NSObject

@property(nonatomic,strong)FSDraftInfo *tempInfo;


+(instancetype)sharedManager;
// 原始数据 与临时数据
-(void)clearInfo;
-(void)mergeInfo;
-(void)saveToLocal;
-(void)cancleOperate;
-(void)delete:(FSDraftInfo *)draftInfo;
-(FSDraftInfo *)draftInfoWithPreInfo:(FSDraftInfo *)preDraftInfo;
-(NSArray *)allDraftInfos;
-(void)setCacheKey:(NSString *)cacheKey;
@end
