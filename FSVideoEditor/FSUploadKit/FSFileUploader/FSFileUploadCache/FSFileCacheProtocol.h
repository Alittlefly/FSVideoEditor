//
//  FSFileCacheProtocol.h
//  FSUploadDemo
//
//  Created by Charles on 2017/5/18.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSFileSlice.h"
@protocol FSFileCacheProtocol <NSObject>
// 将要上传的文件片段
+(void)fileUploadCache:(NSString *)cacheKey cacheDatas:(NSArray *)cachedatas;
// 未上传的文件片段
+(NSArray *)fileUploadCache:(NSString *)cacheKey;
// 将文件标记为已经完成上传
+(void)fileUploadCacheComplete:(NSString *)cacheKey;
// 检查文件是否已经完成上传
+(BOOL)fileUploadIsCompleted:(NSString *)cacheKey;
// 更新文件碎片的状态
+(void)fileUploadSuccess:(FSFileSlice *)fileSlice cacheKey:(NSString *)cacheKey;
// 文件上传的进度
+(float )fileUploadProgress:(NSString *)cacheKey;
@end
