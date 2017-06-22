//
//  FSFileDownloadCache.h
//  FSUploadDemo
//
//  Created by Charles on 2017/3/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSFileDownloadCache : NSObject
// 存储已下载的片段
+(void)fileDownLoadCache:(NSString *)fileUrl downLoadedFiles:(NSArray *)downLoadedFiles;
// 移除所有已下载片段的标记
+(void)fileDownLoadCacheRemoveCache:(NSString *)fileUrl;
// 当前已下载的文件片段
+(NSArray *)fileDownLoadCachedFiles:(NSString *)fileUrl;
// 检查是否已经下载
+(BOOL)isCompleteDownloadFile:(NSString *)fileUrl;
// 检查
@end
