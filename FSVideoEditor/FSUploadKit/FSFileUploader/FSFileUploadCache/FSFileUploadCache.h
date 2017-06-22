//
//  FSFileUploadCache.h
//  FSUploadDemo
//
//  Created by Charles on 2017/3/16.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSFileCacheProtocol.h"

@interface FSFileUploadCache : NSObject<FSFileCacheProtocol>

// 添加等待上传的文件
+(void)fileUploadCacheUpdateWaitingFile:(NSDictionary *)waitData;
// 获取等待上传的文件
+(NSDictionary *)fileUploadCacheGetWaitingFiles;
// 获取已经上传完成的文件
+(NSDictionary *)fileUploadCacheGetFinishedFiles;
// 获取正在处理中的文件
+(NSDictionary *)fileUploadCacheGetProcessingFiles;
// 获取所有的文件的信息
+(NSDictionary *)fileUploadCacheGetAllFiles;


@end
